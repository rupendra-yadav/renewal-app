import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AddRenewalScreen extends StatefulWidget {
  const AddRenewalScreen({super.key});

  @override
  State<AddRenewalScreen> createState() => _AddRenewalScreenState();
}

class _AddRenewalScreenState extends State<AddRenewalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _clientCtrl = TextEditingController();
  final _itemCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _purchaseDateCtrl = TextEditingController();
  final _renewalDateCtrl = TextEditingController();

  // State
  String _selectedType = 'Domain';
  String _selectedCycle = 'Yearly';
  final Set<int> _selectedReminders = {7};
  bool _autoRenew = false;

  static const _types = ['Domain', 'Server', 'SSL', 'Hosting'];
  static const _cycles = ['Monthly', 'Yearly'];
  static const _reminders = [7, 15, 30];

  @override
  void dispose() {
    _clientCtrl.dispose();
    _itemCtrl.dispose();
    _providerCtrl.dispose();
    _amountCtrl.dispose();
    _purchaseDateCtrl.dispose();
    _renewalDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      ctrl.text =
          '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Renewal saved successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Renewal',
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: AppTextSize.lg),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Client & Item ─────────────────────
              _FormSection(
                title: 'Basic Info',
                children: [
                  CustomTextField(
                    label: 'Client Name',
                    hint: 'e.g. RetailIO Pvt Ltd',
                    controller: _clientCtrl,
                    prefixIcon:
                        const Icon(Icons.person_outline, size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Item Name',
                    hint: 'e.g. retailio.in',
                    controller: _itemCtrl,
                    prefixIcon:
                        const Icon(Icons.label_outline, size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Provider',
                    hint: 'e.g. GoDaddy',
                    controller: _providerCtrl,
                    prefixIcon:
                        const Icon(Icons.business_outlined, size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Type ──────────────────────────────
              _FormSection(
                title: 'Renewal Type',
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _types.map((t) {
                      final selected = _selectedType == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedType = t),
                        labelStyle: TextStyle(
                          fontSize: AppTextSize.sm,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : AppColors.cardBorder,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill)),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Dates ─────────────────────────────
              _FormSection(
                title: 'Dates',
                children: [
                  CustomTextField(
                    label: 'Purchase Date',
                    controller: _purchaseDateCtrl,
                    readOnly: true,
                    onTap: () => _pickDate(_purchaseDateCtrl),
                    prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Select date' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Renewal Date',
                    controller: _renewalDateCtrl,
                    readOnly: true,
                    onTap: () => _pickDate(_renewalDateCtrl),
                    prefixIcon: const Icon(
                        Icons.event_available_outlined,
                        size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Select date' : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Amount & Billing ──────────────────
              _FormSection(
                title: 'Pricing',
                children: [
                  CustomTextField(
                    label: 'Amount (₹)',
                    hint: '0',
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(
                        Icons.currency_rupee_rounded,
                        size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Billing cycle dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCycle,
                    decoration: InputDecoration(
                      labelText: 'Billing Cycle',
                      prefixIcon: const Icon(
                          Icons.repeat_rounded,
                          size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md),
                    ),
                    items: _cycles
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCycle = v ?? 'Yearly'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Reminders ─────────────────────────
              _FormSection(
                title: 'Remind me before',
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _reminders.map((days) {
                      final selected = _selectedReminders.contains(days);
                      return FilterChipWidget(
                        label: '$days days',
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selectedReminders.add(days);
                            } else {
                              _selectedReminders.remove(days);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Auto-renew toggle ─────────────────
              Card(
                child: SwitchListTile(
                  title: const Text(
                    'Auto-renew',
                    style: TextStyle(
                        fontSize: AppTextSize.md,
                        fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Automatically renew before expiry',
                    style: TextStyle(
                        fontSize: AppTextSize.sm,
                        color: AppColors.textSecondary),
                  ),
                  value: _autoRenew,
                  onChanged: (v) => setState(() => _autoRenew = v),
                  activeColor: AppColors.primary,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Save button ───────────────────────
              PrimaryButton(label: 'Save Renewal', onPressed: _save),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Titled group container for form fields.
class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: AppTextSize.md,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children),
          ),
        ),
      ],
    );
  }
}
