import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';

// ─────────────────────────────────────────────────
// 1. PrimaryButton
// ─────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? prefixIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: AppSpacing.sm)
                ],
                Text(label),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────
// 2. CustomTextField
// ─────────────────────────────────────────────────
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 3. StatCard  –  Dashboard summary tiles
// ─────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final Color? iconBg;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final bg = iconBg ?? AppColors.primary.withOpacity(0.08);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              // child: Icon(icon, size: 18, color: valueColor ?? AppColors.primary),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: AppTextSize.xxl,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            // const SizedBox(height: AppSpacing.md),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: const TextStyle(
                  fontSize: AppTextSize.xs, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 4. RenewalCard  –  used in lists
// ─────────────────────────────────────────────────
class RenewalCard extends StatelessWidget {
  final Renewal renewal;
  final String? urgencyLabel; // e.g. "2 days"

  const RenewalCard({super.key, required this.renewal, this.urgencyLabel});

  Color get _statusBg {
    switch (renewal.status) {
      case RenewalStatus.expired:
        return AppColors.expired;
      case RenewalStatus.dueSoon:
        return AppColors.dueSoon;
      case RenewalStatus.active:
        return AppColors.active;
    }
  }

  Color get _statusText {
    switch (renewal.status) {
      case RenewalStatus.expired:
        return AppColors.expiredText;
      case RenewalStatus.dueSoon:
        return AppColors.dueSoonText;
      case RenewalStatus.active:
        return AppColors.activeText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: name + urgency badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    renewal.itemName,
                    style: const TextStyle(
                        fontSize: AppTextSize.lg, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (urgencyLabel != null)
                  _Badge(
                      label: urgencyLabel!,
                      bg: AppColors.expired,
                      fg: AppColors.expiredText),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Row 2: client + provider
            Text(
              '${renewal.clientName} · ${renewal.provider}',
              style: const TextStyle(
                  fontSize: AppTextSize.sm, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            // Row 3: tags
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _TagChip(label: renewal.typeLabel),
                if (renewal.autoRenew) const _TagChip(label: 'Auto-renew'),
                _Badge(
                  label: renewal.statusLabel,
                  bg: _statusBg,
                  fg: _statusText,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.md),
            // Row 4: date + amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatDate(renewal.renewalDate),
                      style: const TextStyle(
                          fontSize: AppTextSize.sm,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _TagChip(
                        label: renewal.billingCycle, textSize: AppTextSize.xs),
                  ],
                ),
                Text(
                  renewal.amount == 0
                      ? 'Free'
                      : '₹${renewal.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: AppTextSize.md,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
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
// 5. SectionHeader
// ─────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: AppTextSize.lg, fontWeight: FontWeight.w700)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                  fontSize: AppTextSize.sm,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────
// 6. FilterChipWidget
// ─────────────────────────────────────────────────
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final void Function(bool) onSelected;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: AppTextSize.sm,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      side: BorderSide(
          color: selected ? AppColors.primary : AppColors.cardBorder),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill)),
    );
  }
}

// ─────────────────────────────────────────────────
// Private helpers
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
