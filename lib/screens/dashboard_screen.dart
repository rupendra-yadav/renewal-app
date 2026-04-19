import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../data/dummy_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar / Header ────────────────────
          SliverToBoxAdapter(child: _DashboardHeader()),
          // ── Stats grid ──────────────────────────
          // const SliverToBoxAdapter(child: _StatsSection()),
          // ── Urgent renewals ─────────────────────
          const SliverToBoxAdapter(child: _UrgentSection()),
          // ── Due soon ────────────────────────────
          const SliverToBoxAdapter(child: _DueSoonSection()),
          // ── Monthly overview ────────────────────
          const SliverToBoxAdapter(child: _MonthlyOverviewSection()),
          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning 👋',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: AppTextSize.sm),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Rahul Kumar',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTextSize.xxl,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              // Avatar
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'RK',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTextSize.sm,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _StatsSection(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Stats Grid (2 × 2)
// ─────────────────────────────────────────────────
class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.7,
        children: const [
          StatCard(
            title: 'Total Renewals',
            value: '12',
            icon: Icons.autorenew_rounded,
          ),
          StatCard(
            title: 'Expired',
            value: '3',
            icon: Icons.error_outline_rounded,
            valueColor: AppColors.expiredText,
            iconBg: AppColors.expired,
          ),
          StatCard(
            title: 'Due Soon',
            value: '5',
            icon: Icons.schedule_rounded,
            valueColor: AppColors.dueSoonText,
            iconBg: AppColors.dueSoon,
          ),
          StatCard(
            title: 'This Year Revenue',
            value: '₹42k',
            icon: Icons.currency_rupee_rounded,
            valueColor: AppColors.activeText,
            iconBg: AppColors.active,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Urgent Renewals
// ─────────────────────────────────────────────────
class _UrgentSection extends StatelessWidget {
  const _UrgentSection();

  String _daysLabel(DateTime dt) {
    final diff = dt.difference(DateTime.now()).inDays;
    if (diff <= 0) return 'Today';
    return '$diff ${diff == 1 ? 'day' : 'days'}';
  }

  @override
  Widget build(BuildContext context) {
    final urgent = DummyData.urgentRenewals;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          SectionHeader(
            title: '🔴 Urgent Renewals',
            actionLabel: 'See all',
            onAction: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          ...urgent.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: RenewalCard(
                  renewal: r,
                  urgencyLabel: _daysLabel(r.renewalDate),
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Due Soon
// ─────────────────────────────────────────────────
class _DueSoonSection extends StatelessWidget {
  const _DueSoonSection();

  @override
  Widget build(BuildContext context) {
    final due = DummyData.dueSoonRenewals;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
      child: Column(
        children: [
          SectionHeader(
            title: '🟡 Due Soon',
            actionLabel: 'See all',
            onAction: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          ...due.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: RenewalCard(renewal: r),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Monthly Overview
// ─────────────────────────────────────────────────
class _MonthlyOverviewSection extends StatelessWidget {
  const _MonthlyOverviewSection();

  static const _months = [
    _MonthData('Apr – Jun', 4, 12800, 0.7),
    _MonthData('Jul – Sep', 3, 9600, 0.55),
    _MonthData('Oct – Dec', 5, 17400, 0.9),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          const SectionHeader(title: '📅 Monthly Overview'),
          const SizedBox(height: AppSpacing.md),
          ...(_months.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _MonthCard(data: m),
              ))),
        ],
      ),
    );
  }
}

class _MonthData {
  final String label;
  final int count;
  final double amount;
  final double progress;
  const _MonthData(this.label, this.count, this.amount, this.progress);
}

class _MonthCard extends StatelessWidget {
  final _MonthData data;
  const _MonthCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data.label,
                    style: const TextStyle(
                        fontSize: AppTextSize.md, fontWeight: FontWeight.w700)),
                Text(
                  '${data.count} renewals',
                  style: const TextStyle(
                      fontSize: AppTextSize.sm, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${(data.amount / 1000).toStringAsFixed(1)}k',
                  style: const TextStyle(
                      fontSize: AppTextSize.xl,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
                Text(
                  '${(data.progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: AppTextSize.sm,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: data.progress,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
