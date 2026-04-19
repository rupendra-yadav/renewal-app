import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../data/dummy_data.dart';

class RenewalListScreen extends StatefulWidget {
  const RenewalListScreen({super.key});

  @override
  State<RenewalListScreen> createState() => _RenewalListScreenState();
}

class _RenewalListScreenState extends State<RenewalListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Urgent', 'Due soon', 'Domain', 'Server'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Renewal> get _filtered {
    var list = DummyData.renewals;

    // Apply type/status filter
    switch (_selectedFilter) {
      case 'Urgent':
        list = list.where((r) => r.status == RenewalStatus.expired).toList();
        break;
      case 'Due soon':
        list = list.where((r) => r.status == RenewalStatus.dueSoon).toList();
        break;
      case 'Domain':
        list = list.where((r) => r.type == RenewalType.domain).toList();
        break;
      case 'Server':
        list = list.where((r) => r.type == RenewalType.server).toList();
        break;
    }

    // Apply search query
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

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          // ── Sticky top bar ──────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + AppSpacing.lg,
                  bottom: AppSpacing.xl,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Renewals',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTextSize.xxl,
                              fontWeight: FontWeight.w800),
                        ),
                        // Add button
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed('/add-renewal'),
                          child: Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4)),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Search bar below the header (in app bar bottom)
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
                child: _SearchBar(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // ── Filter chips ────────────────────────
            _FilterRow(
              filters: _filters,
              selected: _selectedFilter,
              onSelected: (f) => setState(() => _selectedFilter = f),
            ),
            // ── List ────────────────────────────────
            Expanded(
              child: results.isEmpty
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
                          child: RenewalCard(
                            renewal: r,
                            urgencyLabel: r.status == RenewalStatus.expired
                                ? _urgency(r.renewalDate)
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _urgency(DateTime dt) {
    final diff = dt.difference(DateTime.now()).inDays;
    if (diff <= 0) return 'Today';
    return '$diff ${diff == 1 ? 'day' : 'days'}';
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
        border:
            Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: AppTextSize.sm),
        decoration: InputDecoration(
          hintText: 'Search renewals…',
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: AppTextSize.sm),
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
// Filter row
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
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppSpacing.sm),
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
          const Text(
            'No renewals found',
            style: TextStyle(
                fontSize: AppTextSize.lg, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Try changing the filter or search term.',
            style: TextStyle(
                fontSize: AppTextSize.sm, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
