import 'package:flutter/material.dart';
import 'package:renewtrack/services/apiService.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class RenewalListScreen extends StatefulWidget {
  /// When non-null, the list opens pre-filtered to this month (1–12).
  final int? initialMonth;

  const RenewalListScreen({super.key, this.initialMonth});

  @override
  State<RenewalListScreen> createState() => _RenewalListScreenState();
}

class _RenewalListScreenState extends State<RenewalListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedFilter = 'All';
  int? _selectedMonth; // null = all months

  List<RenewalItem> _allRenewals = [];
  bool _loading = true;
  String? _error;

  static const _filters = ['All', 'Urgent', 'Due soon', 'Active'];
  static const _monthNames = [
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
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _fetchRenewals();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchRenewals() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.instance.getRenewals();
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() {
        _allRenewals = result.data!;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _loading = false;
      });
    }
  }

  List<RenewalItem> get _filtered {
    var list = _allRenewals;

    // Month filter (applied first)
    if (_selectedMonth != null) {
      list = list.where((r) => r.renewalDate.month == _selectedMonth).toList();
    }

    // Status filter
    switch (_selectedFilter) {
      case 'Urgent':
        list = list.where((r) => r.isExpired).toList();
        break;
      case 'Due soon':
        list = list.where((r) => r.isDueSoon).toList();
        break;
      case 'Active':
        list = list.where((r) => !r.isExpired).toList();
        break;
    }

    // Search
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((r) =>
              r.itemName.toLowerCase().contains(q) ||
              r.clientName.toLowerCase().contains(q) ||
              r.provider.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  // Only show months that actually have at least one renewal
  List<int> get _availableMonths {
    final months =
        _allRenewals.map((r) => r.renewalDate.month).toSet().toList();
    months.sort();
    return months;
  }

  String _urgencyLabel(RenewalItem r) {
    final diff = r.renewalDate.difference(DateTime.now()).inDays;
    if (r.isExpired) {
      if (diff == 0) return 'Today';
      return '${diff.abs()} ${diff.abs() == 1 ? 'day' : 'days'} ago';
    }
    if (diff <= 0) return 'Today';
    return 'in $diff ${diff == 1 ? 'day' : 'days'}';
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    final topPad = MediaQuery.of(context).padding.top;
    // Title changes when a month is selected
    final title = _selectedMonth != null
        ? '${_monthNames[_selectedMonth! - 1]} Renewals'
        : 'Renewals';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Custom header ──────────────────────────────────────
          Container(
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
              top: topPad + AppSpacing.lg,
              bottom: AppSpacing.xl,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Back button only when pushed from dashboard
                    if (widget.initialMonth != null) ...[
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 38,
                          width: 38,
                          margin: const EdgeInsets.only(right: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppTextSize.xxl,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final refreshed = await Navigator.of(context)
                            .pushNamed('/add-renewal');
                        if (refreshed == true) _fetchRenewals();
                      },
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SearchBar(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),

          // ── Month filter (visible once data loads) ─────────────
          if (!_loading && _availableMonths.isNotEmpty)
            _MonthFilterRow(
              availableMonths: _availableMonths,
              selectedMonth: _selectedMonth,
              // Tap same month again → deselect (show all)
              onSelected: (m) => setState(
                  () => _selectedMonth = _selectedMonth == m ? null : m),
            ),

          // ── Status filter chips ────────────────────────────────
          _FilterRow(
            filters: _filters,
            selected: _selectedFilter,
            onSelected: (f) => setState(() => _selectedFilter = f),
          ),

          // ── List ───────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchRenewals,
              child: _loading
                  ? const _LoadingList()
                  : _error != null
                      ? _ErrorState(message: _error!, onRetry: _fetchRenewals)
                      : results.isEmpty
                          ? const _EmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl,
                                  AppSpacing.md,
                                  AppSpacing.xl,
                                  AppSpacing.xxxl),
                              itemCount: results.length,
                              itemBuilder: (_, i) {
                                final r = results[i];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md),
                                  child: _ApiRenewalCard(
                                    item: r,
                                    urgencyLabel: _urgencyLabel(r),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Month filter row
// ─────────────────────────────────────────────────
class _MonthFilterRow extends StatelessWidget {
  final List<int> availableMonths;
  final int? selectedMonth;
  final void Function(int) onSelected;

  static const _monthNames = [
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
    'Dec',
  ];

  const _MonthFilterRow({
    required this.availableMonths,
    required this.selectedMonth,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by month',
            style: TextStyle(
              fontSize: AppTextSize.xs,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withOpacity(0.7),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: availableMonths.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (_, i) {
                final month = availableMonths[i];
                final isSelected = selectedMonth == month;
                return GestureDetector(
                  onTap: () => onSelected(month),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      _monthNames[month - 1],
                      style: TextStyle(
                        fontSize: AppTextSize.sm,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Renewal card
// ─────────────────────────────────────────────────
class _ApiRenewalCard extends StatelessWidget {
  final RenewalItem item;
  final String urgencyLabel;

  const _ApiRenewalCard({required this.item, required this.urgencyLabel});

  bool get _isExpired => item.isExpired;
  Color get _statusBg => _isExpired ? AppColors.expired : AppColors.dueSoon;
  Color get _statusText =>
      _isExpired ? AppColors.expiredText : AppColors.dueSoonText;
  String get _statusLabel => _isExpired ? 'Expired' : 'Due soon';

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
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                _RenewalBadge(
                    label: urgencyLabel, bg: _statusBg, fg: _statusText),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
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
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _RenewalTagChip(label: item.type),
                if (item.autoRenew) const _RenewalTagChip(label: 'Auto-renew'),
                _RenewalBadge(
                    label: _statusLabel, bg: _statusBg, fg: _statusText),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.md),
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
                    _RenewalTagChip(
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
}

// ─────────────────────────────────────────────────
// Loading skeleton
// ─────────────────────────────────────────────────
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Container(
          height: 130,
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
              _shimmer(width: 160, height: 14),
              _shimmer(width: 110, height: 11),
              _shimmer(width: double.infinity, height: 8),
              _shimmer(width: 80, height: 11),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmer({required double width, required double height}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      );
}

// ─────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: AppTextSize.sm, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: AppTextSize.sm),
        decoration: InputDecoration(
          hintText: 'Search renewals…',
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.65), fontSize: AppTextSize.sm),
          prefixIcon: Icon(Icons.search,
              color: Colors.white.withOpacity(0.8), size: 18),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.white.withOpacity(0.8), size: 16),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: false,
        ),
        cursorColor: Colors.white,
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Status filter row
// ─────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final void Function(String) onSelected;

  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final f = filters[i];
            return FilterChipWidget(
              label: f,
              selected: selected == f,
              onSelected: (_) => onSelected(f),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('No renewals found',
              style: TextStyle(
                  fontSize: AppTextSize.lg, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          const Text('Try changing the filter or search term.',
              style: TextStyle(
                  fontSize: AppTextSize.sm, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Badge + chip
// ─────────────────────────────────────────────────
class _RenewalBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _RenewalBadge(
      {required this.label, required this.bg, required this.fg});

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

class _RenewalTagChip extends StatelessWidget {
  final String label;
  final double textSize;

  const _RenewalTagChip({required this.label, this.textSize = AppTextSize.xs});

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
