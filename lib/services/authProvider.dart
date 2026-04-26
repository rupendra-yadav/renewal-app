import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:renewtrack/services/apiService.dart';

/// Holds the currently authenticated user and drives UI rebuilds.
///
/// Wrap your widget tree with [ChangeNotifierProvider<AuthProvider>] (or use
/// the lightweight InheritedWidget helper below) to propagate auth state.
class AuthProvider extends ChangeNotifier {
  UserProfile? _user;
  String? _error;
  bool _loading = false;

  UserProfile? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  /// Calls [ApiService.login] and updates state.
  Future<bool> login({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result =
        await ApiService.instance.login(email: email, password: password);

    _loading = false;

    if (result.isSuccess) {
      _user = result.data!.user;
      _error = null;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.instance.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────
// Minimal InheritedNotifier — avoids adding provider package
// ─────────────────────────────────────────────────

/// Wrap [MaterialApp] (or any subtree) with this to share [AuthProvider].
///
/// ```dart
/// AuthScope(
///   notifier: AuthProvider(),
///   child: MaterialApp(...),
/// )
/// ```
class AuthScope extends InheritedNotifier<AuthProvider> {
  const AuthScope({
    super.key,
    required AuthProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Access [AuthProvider] from any descendant widget.
  static AuthProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found in widget tree');
    return scope!.notifier!;
  }
}
