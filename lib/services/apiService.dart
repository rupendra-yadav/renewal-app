import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────
// Generic API result wrapper
// ─────────────────────────────────────────────────

class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  const ApiResult.success(this.data)
      : error = null,
        statusCode = null;

  const ApiResult.failure(this.error, {this.statusCode}) : data = null;

  bool get isSuccess => data != null && error == null;
}

// ─────────────────────────────────────────────────
// Auth models
// ─────────────────────────────────────────────────

class LoginResponse {
  final String token;
  final UserProfile user;

  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] as Map<String, dynamic>? ?? json;
    return LoginResponse(
      token: payload['token'] as String? ??
          payload['access_token'] as String? ??
          '',
      user:
          UserProfile.fromJson(payload['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class UserProfile {
  final int? id;
  final String name;
  final String email;
  final String? avatar;

  const UserProfile({
    this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 2).toUpperCase() : 'RT';
  }
}

// ─────────────────────────────────────────────────
// Dashboard models
// ─────────────────────────────────────────────────

/// Top-level stats block from GET /renewals/dashboard
class DashboardStats {
  final int totalRenewals;
  final int upcomingCount;
  final int expiredCount;
  final double totalAmount;

  const DashboardStats({
    required this.totalRenewals,
    required this.upcomingCount,
    required this.expiredCount,
    required this.totalAmount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRenewals: json['totalRenewals'] as int? ?? 0,
      upcomingCount: json['upcomingCount'] as int? ?? 0,
      expiredCount: json['expiredCount'] as int? ?? 0,
      totalAmount:
          ((json['amounts'] as Map<String, dynamic>?)?['total'] as num?)
                  ?.toDouble() ??
              0.0,
    );
  }
}

/// One month's totals inside monthWiseStats.months
class MonthStat {
  final String month;
  final int monthNumber;
  final int count;
  final double amount;

  const MonthStat({
    required this.month,
    required this.monthNumber,
    required this.count,
    required this.amount,
  });

  factory MonthStat.fromJson(Map<String, dynamic> json) {
    final total = json['total'] as Map<String, dynamic>? ?? {};
    return MonthStat(
      month: json['month'] as String? ?? '',
      monthNumber: json['monthNumber'] as int? ?? 0,
      count: total['count'] as int? ?? 0,
      amount: (total['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// A single renewal item returned in upcomingRenewals / expiredRenewals
class RenewalItem {
  final String id;
  final String itemName;
  final String clientName;
  final String provider;
  final String type;
  final DateTime renewalDate;
  final double amount;
  final String billingCycle;
  final bool autoRenew;

  const RenewalItem({
    required this.id,
    required this.itemName,
    required this.clientName,
    required this.provider,
    required this.type,
    required this.renewalDate,
    required this.amount,
    required this.billingCycle,
    required this.autoRenew,
  });

  factory RenewalItem.fromJson(Map<String, dynamic> json) {
    // client arrives as a nested object { _id, companyName }, not a flat string
    final clientRaw = json['client'];
    final String clientName;
    if (clientRaw is Map<String, dynamic>) {
      clientName = clientRaw['companyName'] as String? ?? '';
    } else {
      clientName = json['clientName'] as String? ?? clientRaw?.toString() ?? '';
    }

    return RenewalItem(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '', // API uses _id
      itemName: json['itemName'] as String? ??
          json['name'] as String? ??
          json['domain'] as String? ??
          '',
      clientName: clientName,
      provider: json['provider'] as String? ?? '',
      type: json['type'] as String? ?? 'Domain',
      renewalDate: json['renewalDate'] != null
          ? DateTime.tryParse(json['renewalDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      billingCycle: json['billingCycle'] as String? ?? 'Yearly',
      autoRenew: json['autoRenew'] as bool? ?? false,
    );
  }

  // Add to RenewalItem class
  bool get isExpired => renewalDate.isBefore(DateTime.now());
  bool get isDueSoon {
    final diff = renewalDate.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 30;
  }
}

/// Full dashboard response
class DashboardResponse {
  final DashboardStats stats;
  final int monthWiseYear;
  final List<MonthStat> monthWiseStats;
  final List<RenewalItem> upcomingRenewals;
  final List<RenewalItem> expiredRenewals;

  const DashboardResponse({
    required this.stats,
    required this.monthWiseYear,
    required this.monthWiseStats,
    required this.upcomingRenewals,
    required this.expiredRenewals,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    // Parse stats
    final statsJson = json['stats'] as Map<String, dynamic>? ?? {};
    final stats = DashboardStats.fromJson(statsJson);

    // Parse monthWiseStats
    final mws = json['monthWiseStats'] as Map<String, dynamic>? ?? {};
    final year = mws['year'] as int? ?? DateTime.now().year;
    final monthsList = (mws['months'] as List<dynamic>? ?? [])
        .map((m) => MonthStat.fromJson(m as Map<String, dynamic>))
        .toList();

    // Parse upcoming + expired renewals
    final upcoming = (json['upcomingRenewals'] as List<dynamic>? ?? [])
        .map((r) => RenewalItem.fromJson(r as Map<String, dynamic>))
        .toList();
    final expired = (json['expiredRenewals'] as List<dynamic>? ?? [])
        .map((r) => RenewalItem.fromJson(r as Map<String, dynamic>))
        .toList();

    return DashboardResponse(
      stats: stats,
      monthWiseYear: year,
      monthWiseStats: monthsList,
      upcomingRenewals: upcoming,
      expiredRenewals: expired,
    );
  }
}

// ─────────────────────────────────────────────────
// ApiService  (singleton)
// ─────────────────────────────────────────────────

class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  static const String _baseUrl = 'https://lx.webdevelopercg.com/api';
  static const Duration _timeout = Duration(seconds: 15);

  String? _authToken;
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  void setToken(String token) => _authToken = token;
  void clearToken() => _authToken = null;

  Map<String, String> get _baseHeaders => {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        if (isAuthenticated)
          HttpHeaders.authorizationHeader: 'Bearer $_authToken',
      };

  // ── Core HTTP helpers ────────────────────────

  Future<ApiResult<Map<String, dynamic>>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    debugPrint('[API] POST $uri');
    try {
      final response = await http
          .post(uri, headers: _baseHeaders, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return const ApiResult.failure(
          'No internet connection. Please check your network.');
    } on HttpException {
      return const ApiResult.failure('Unable to reach the server.');
    } on FormatException {
      return const ApiResult.failure('Unexpected response format.');
    } catch (e) {
      return ApiResult.failure('Something went wrong: $e');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> _get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    debugPrint('[API] GET $uri');
    try {
      final response =
          await http.get(uri, headers: _baseHeaders).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return const ApiResult.failure(
          'No internet connection. Please check your network.');
    } on HttpException {
      return const ApiResult.failure('Unable to reach the server.');
    } on FormatException {
      return const ApiResult.failure('Unexpected response format.');
    } catch (e) {
      return ApiResult.failure('Something went wrong: $e');
    }
  }

  ApiResult<Map<String, dynamic>> _handleResponse(http.Response response) {
    debugPrint('[API] ${response.statusCode} ${response.request?.url}');
    final int code = response.statusCode;
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      json = null;
    }
    if (code >= 200 && code < 300) return ApiResult.success(json ?? {});
    final msg = json?['message'] as String? ??
        json?['error'] as String? ??
        _defaultMessage(code);
    return ApiResult.failure(msg, statusCode: code);
  }

  String _defaultMessage(int code) {
    switch (code) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Incorrect email or password.';
      case 403:
        return 'You do not have permission to do that.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'An unexpected error occurred (HTTP $code).';
    }
  }

  Future<ApiResult<List<dynamic>>> _getList(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    debugPrint('[API] GET $uri');
    try {
      final response =
          await http.get(uri, headers: _baseHeaders).timeout(_timeout);
      debugPrint('[API] ${response.statusCode} ${response.request?.url}');
      final code = response.statusCode;
      if (code >= 200 && code < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return ApiResult.success(decoded);
        // Some APIs wrap the list: { data: [...] }
        if (decoded is Map && decoded['data'] is List) {
          return ApiResult.success(decoded['data'] as List);
        }
        return const ApiResult.failure('Unexpected response shape.');
      }
      Map<String, dynamic>? json;
      try {
        json = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}
      final msg = json?['message'] as String? ?? _defaultMessage(code);
      return ApiResult.failure(msg, statusCode: code);
    } on SocketException {
      return const ApiResult.failure('No internet connection.');
    } on HttpException {
      return const ApiResult.failure('Unable to reach the server.');
    } on FormatException {
      return const ApiResult.failure('Unexpected response format.');
    } catch (e) {
      return ApiResult.failure('Something went wrong: $e');
    }
  }

  // ── Auth endpoints ───────────────────────────

  /// POST /auth/login
  Future<ApiResult<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    final result = await _post(
      '/auth/login',
      {'email': email.trim(), 'password': password},
    );
    if (!result.isSuccess) {
      return ApiResult.failure(result.error, statusCode: result.statusCode);
    }
    try {
      final loginResp = LoginResponse.fromJson(result.data!);
      if (loginResp.token.isNotEmpty) setToken(loginResp.token);
      return ApiResult.success(loginResp);
    } catch (e) {
      return ApiResult.failure('Failed to parse login response: $e');
    }
  }

  /// POST /auth/logout
  Future<void> logout() async {
    await _post('/auth/logout', {});
    clearToken();
  }

  // ── Dashboard endpoint ───────────────────────

  /// GET /renewals/dashboard
  Future<ApiResult<DashboardResponse>> getDashboard() async {
    final result = await _get('/renewals/dashboard');
    if (!result.isSuccess) {
      return ApiResult.failure(result.error, statusCode: result.statusCode);
    }
    try {
      return ApiResult.success(DashboardResponse.fromJson(result.data!));
    } catch (e) {
      return ApiResult.failure('Failed to parse dashboard data: $e');
    }
  }

  // ── Renewal endpoints ────────────────────────

  /// GET /renewals
  /// GET /renewals
  Future<ApiResult<List<RenewalItem>>> getRenewals({
    String? status,
    String? type,
    String? search,
  }) async {
    final params = <String, String>{
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    // API returns a raw list, not a map — use _getList helper
    final result = await _getList('/renewals', queryParams: params);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error, statusCode: result.statusCode);
    }
    try {
      final items = result.data!
          .map((r) => RenewalItem.fromJson(r as Map<String, dynamic>))
          .toList();
      return ApiResult.success(items);
    } catch (e) {
      return ApiResult.failure('Failed to parse renewals: $e');
    }
  }

  /// POST /renewals
  Future<ApiResult<Map<String, dynamic>>> createRenewal(
      Map<String, dynamic> payload) async {
    return _post('/renewals', payload);
  }
}
