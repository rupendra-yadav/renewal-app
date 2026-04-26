import 'package:flutter/material.dart';
import 'package:renewtrack/screens/renewal_list_screen.dart';
import 'package:renewtrack/services/apiService.dart';
import 'package:renewtrack/services/authProvider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Holds the live API data
  DashboardResponse? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.instance.getDashboard();
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() {
        _data = result.data;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchDashboard,
        child: CustomScrollView(
          slivers: [
            // ── Header (always shown, skeleton on load) ──
            SliverToBoxAdapter(
              child: _DashboardHeader(
                data: _data,
                loading: _loading,
              ),
            ),

            // ── Error banner ─────────────────────────────
            if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                  child: _ErrorRetryBanner(
                    message: _error!,
                    onRetry: _fetchDashboard,
                  ),
                ),
              ),

            // ── Expired / Urgent renewals ─────────────────
            SliverToBoxAdapter(
              child: _RenewalSection(
                title: '🔴 Expired Renewals',
                items: _data?.expiredRenewals ?? [],
                loading: _loading,
                isExpired: true,
              ),
            ),

            // ── Upcoming renewals ─────────────────────────
            SliverToBoxAdapter(
              child: _RenewalSection(
                title: '🟡 Upcoming Renewals',
                items: _data?.upcomingRenewals ?? [],
                loading: _loading,
                isExpired: false,
              ),
            ),

            // ── Monthly overview ──────────────────────────
            SliverToBoxAdapter(
              child: _MonthlyOverviewSection(
                year: _data?.monthWiseYear,
                months: _data?.monthWiseStats ?? [],
                loading: _loading,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Header — greeting + avatar + glass stat cards
// ─────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final DashboardResponse? data;
  final bool loading;

  const _DashboardHeader({required this.data, required this.loading});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final displayName =
        (auth.user?.name.isNotEmpty ?? false) ? auth.user!.name : 'Rahul Kumar';
    final initials = auth.user?.initials ?? _fallbackInitials(displayName);

    // Pull live stats, or zeros while loading
    final stats = data?.stats;
    final total = stats?.totalRenewals ?? 0;
    final expired = stats?.expiredCount ?? 0;
    final upcoming = stats?.upcomingCount ?? 0;
    final revenue = stats?.totalAmount ?? 0.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.lg,
        bottom: AppSpacing.xxl,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting row ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()} 👋',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: AppTextSize.sm,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTextSize.xxl,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              // Avatar → profile sheet
              GestureDetector(
                onTap: () => _showProfileMenu(context, auth),
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppTextSize.sm,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Stats grid ────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.65,
            children: [
              _GlassStatCard(
                title: 'Total Renewals',
                value: loading ? '–' : '$total',
                icon: Icons.autorenew_rounded,
                loading: loading,
              ),
              _GlassStatCard(
                title: 'Expired',
                value: loading ? '–' : '$expired',
                icon: Icons.error_outline_rounded,
                accentColor: const Color(0xFFFF8A80),
                accentBg: const Color(0x33FF5252),
                loading: loading,
              ),
              _GlassStatCard(
                title: 'Upcoming',
                value: loading ? '–' : '$upcoming',
                icon: Icons.schedule_rounded,
                accentColor: const Color(0xFFFFCC80),
                accentBg: const Color(0x33FF9800),
                loading: loading,
              ),
              _GlassStatCard(
                title: 'Revenue (YTD)',
                value: loading ? '–' : _formatAmount(revenue),
                icon: Icons.currency_rupee_rounded,
                accentColor: const Color(0xFFA5D6A7),
                accentBg: const Color(0x334CAF50),
                loading: loading,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats ₹ amounts: ₹1.2k, ₹3.4L, etc.
  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _fallbackInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 2).toUpperCase() : 'RT';
  }

  void _showProfileMenu(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _ProfileSheet(auth: auth),
    );
  }
}

// ─────────────────────────────────────────────────
// Glass stat card — sits on the purple gradient
// ─────────────────────────────────────────────────
class _GlassStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;
  final bool loading;

  const _GlassStatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor = Colors.white,
    this.accentBg = const Color(0x33FFFFFF),
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon pill
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTextSize.xxl,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          // Value + label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: AppTextSize.xs,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Expired / Upcoming renewal section
// ─────────────────────────────────────────────────
class _RenewalSection extends StatelessWidget {
  final String title;
  final List<RenewalItem> items;
  final bool loading;
  final bool isExpired;

  const _RenewalSection({
    required this.title,
    required this.items,
    required this.loading,
    required this.isExpired,
  });

  String _daysLabel(DateTime dt) {
    final diff = dt.difference(DateTime.now()).inDays;
    if (isExpired) {
      if (diff >= 0) return 'Today';
      return '${diff.abs()} ${diff.abs() == 1 ? 'day' : 'days'} ago';
    }
    if (diff <= 0) return 'Today';
    return 'in $diff ${diff == 1 ? 'day' : 'days'}';
  }

  @override
  Widget build(BuildContext context) {
    // Don't render the section if not loading and list is empty
    if (!loading && items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            actionLabel: 'See all',
            onAction: () {},
          ),
          const SizedBox(height: AppSpacing.md),

          // Skeleton shimmer while loading
          if (loading)
            ...[1, 2].map((_) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SkeletonCard(),
                )),

          // Real cards
          if (!loading)
            ...items.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ApiRenewalCard(
                  item: r,
                  urgencyLabel: _daysLabel(r.renewalDate),
                  isExpired: isExpired,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Card for RenewalItem from API
// ─────────────────────────────────────────────────
class _ApiRenewalCard extends StatelessWidget {
  final RenewalItem item;
  final String urgencyLabel;
  final bool isExpired;

  const _ApiRenewalCard({
    required this.item,
    required this.urgencyLabel,
    required this.isExpired,
  });

  Color get _statusBg => isExpired ? AppColors.expired : AppColors.dueSoon;
  Color get _statusText =>
      isExpired ? AppColors.expiredText : AppColors.dueSoonText;
  String get _statusLabel => isExpired ? 'Expired' : 'Due soon';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: name + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: AppTextSize.lg,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _Badge(
                  label: urgencyLabel,
                  bg: _statusBg,
                  fg: _statusText,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Client + provider
            Text(
              [
                if (item.clientName.isNotEmpty) item.clientName,
                if (item.provider.isNotEmpty) item.provider,
              ].join(' · '),
              style: const TextStyle(
                fontSize: AppTextSize.sm,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tags row
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _TagChip(label: item.type),
                if (item.autoRenew) const _TagChip(label: 'Auto-renew'),
                _Badge(
                  label: _statusLabel,
                  bg: _statusBg,
                  fg: _statusText,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.md),

            // Date + amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatDate(item.renewalDate),
                      style: const TextStyle(
                        fontSize: AppTextSize.sm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _TagChip(
                        label: item.billingCycle, textSize: AppTextSize.xs),
                  ],
                ),
                Text(
                  item.amount == 0
                      ? 'Free'
                      : '₹${item.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: AppTextSize.md,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ─────────────────────────────────────────────────
// Monthly Overview — month-wise from API
// ─────────────────────────────────────────────────
class _MonthlyOverviewSection extends StatelessWidget {
  final int? year;
  final List<MonthStat> months;
  final bool loading;

  const _MonthlyOverviewSection({
    required this.year,
    required this.months,
    required this.loading,
  });

  // Filter to only months that have data, or all if loading
  List<MonthStat> get _activeMonths =>
      loading ? [] : months.where((m) => m.count > 0 || m.amount > 0).toList();

  // Max amount for normalising the progress bar
  double get _maxAmount {
    if (_activeMonths.isEmpty) return 1;
    return _activeMonths
        .map((m) => m.amount)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final hasData = !loading && _activeMonths.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: '📅 Monthly Overview${year != null ? ' ($year)' : ''}',
          ),
          const SizedBox(height: AppSpacing.md),

          // Skeleton
          if (loading)
            ...[1, 2, 3].map((_) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SkeletonCard(height: 84),
                )),

          // Empty state
          if (!loading && !hasData)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        color: AppColors.textSecondary.withOpacity(0.4),
                        size: 28),
                    const SizedBox(width: AppSpacing.md),
                    const Text(
                      'No monthly data yet for this year.',
                      style: TextStyle(
                          fontSize: AppTextSize.sm,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

          // Real data
          if (hasData)
            ..._activeMonths.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _MonthCard(stat: m, maxAmount: _maxAmount),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Replace the existing _MonthCard class in dashboard_screen.dart
// with this version. No other changes needed in that file.
// ─────────────────────────────────────────────────

class _MonthCard extends StatelessWidget {
  final MonthStat stat;
  final double maxAmount;

  const _MonthCard({required this.stat, required this.maxAmount});

  @override
  Widget build(BuildContext context) {
    final progress = (stat.amount / maxAmount).clamp(0.0, 1.0);

    return GestureDetector(
      // Pass monthNumber so RenewalListScreen opens pre-filtered
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RenewalListScreen(initialMonth: stat.monthNumber),
        ),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stat.month,
                    style: const TextStyle(
                      fontSize: AppTextSize.md,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${stat.count} renewal${stat.count == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: AppTextSize.sm,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stat.amount >= 1000
                        ? '₹${(stat.amount / 1000).toStringAsFixed(1)}k'
                        : '₹${stat.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: AppTextSize.xl,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: AppTextSize.sm,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Profile bottom sheet
// ─────────────────────────────────────────────────
class _ProfileSheet extends StatelessWidget {
  final AuthProvider auth;
  const _ProfileSheet({required this.auth});

  @override
  Widget build(BuildContext context) {
    final name =
        (auth.user?.name.isNotEmpty ?? false) ? auth.user!.name : 'Rahul Kumar';
    final email = auth.user?.email ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  auth.user?.initials ?? 'RT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTextSize.lg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(name,
                style: const TextStyle(
                    fontSize: AppTextSize.lg, fontWeight: FontWeight.w700)),
            if (email.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(email,
                  style: const TextStyle(
                      fontSize: AppTextSize.sm,
                      color: AppColors.textSecondary)),
            ],
            const SizedBox(height: AppSpacing.xxl),
            const Divider(color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.logout_rounded,
                  color: AppColors.expiredText),
              title: const Text('Sign out',
                  style: TextStyle(
                      color: AppColors.expiredText,
                      fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.of(context).pop();
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Error + retry banner
// ─────────────────────────────────────────────────
class _ErrorRetryBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetryBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.expired,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.expiredText.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.expiredText, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: AppTextSize.sm,
                    color: AppColors.expiredText,
                    fontWeight: FontWeight.w500)),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.expiredText,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text('Retry',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTextSize.xs,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Skeleton loading card
// ─────────────────────────────────────────────────
class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _shimmer(width: 140, height: 14),
          _shimmer(width: 100, height: 11),
          _shimmer(width: double.infinity, height: 8),
        ],
      ),
    );
  }

  Widget _shimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Shared small UI helpers (private to this file)
// ─────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label,
          style: TextStyle(
              fontSize: AppTextSize.xs,
              fontWeight: FontWeight.w700,
              color: fg)),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final double textSize;
  const _TagChip({required this.label, this.textSize = AppTextSize.xs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w600,
              color: AppColors.primary)),
    );
  }
}
