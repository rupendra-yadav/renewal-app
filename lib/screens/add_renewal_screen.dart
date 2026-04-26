import 'package:flutter/material.dart';
import 'package:renewtrack/services/apiService.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AddRenewalScreen extends StatefulWidget {
  const AddRenewalScreen({super.key});

  @override
  State<AddRenewalScreen> createState() => _AddRenewalScreenState();
}

class _AddRenewalScreenState extends State<AddRenewalScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Basic info ───────────────────────────────────────────
  final _companyCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // ── Renewal info ─────────────────────────────────────────
  final _itemCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // ── Date pickers (display text only) ─────────────────────
  final _purchaseDateCtrl = TextEditingController();
  final _renewalDateCtrl = TextEditingController();

  // ── Actual DateTime values for API ────────────────────────
  DateTime? _purchaseDate;
  DateTime? _renewalDate;

  // ── Dropdown / chip state ────────────────────────────────
  String _selectedType = 'Domain';
  String _selectedCycle = 'yearly';
  int _reminderDays = 30;
  bool _autoRenew = false;
  bool _saving = false;

  static const _types = ['Domain', 'Server', 'SSL', 'Hosting'];
  static const _cycles = ['monthly', 'yearly'];
  static const _reminders = [7, 15, 30];

  @override
  void dispose() {
    _companyCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _itemCtrl.dispose();
    _providerCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _purchaseDateCtrl.dispose();
    _renewalDateCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ──────────────────────────────────────────
  Future<void> _pickDate(
    TextEditingController displayCtrl,
    void Function(DateTime) onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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
      onPicked(picked);
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
      displayCtrl.text =
          '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    }
  }

  // ── Format DateTime → "YYYY-MM-DD" for API ───────────────
  String _toApiDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // ── Submit ───────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_purchaseDate == null || _renewalDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both dates.')),
      );
      return;
    }

    setState(() => _saving = true);

    final payload = {
      'newClient': {
        'companyName': _companyCtrl.text.trim(),
        'contactPerson': _contactCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      },
      'itemName': _itemCtrl.text.trim(),
      'provider': _providerCtrl.text.trim(),
      'purchaseDate': _toApiDate(_purchaseDate!),
      'renewalDate': _toApiDate(_renewalDate!),
      'amount': double.tryParse(_amountCtrl.text.trim()) ?? 0,
      'currency': 'INR',
      'billingCycle': _selectedCycle, // already lowercase
      'autoRenew': _autoRenew,
      'reminderDaysBefore': _reminderDays,
      'status': 'active',
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };

    final result = await ApiService.instance.createRenewal(payload);

    if (!mounted) return;
    setState(() => _saving = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Renewal saved successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      );
      Navigator.of(context).pop(true); // pass true so list can refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to save renewal.'),
          backgroundColor: AppColors.expiredText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      );
    }
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
          style:
              TextStyle(fontWeight: FontWeight.w700, fontSize: AppTextSize.lg),
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
              // ── Client details ───────────────────────────────
              _FormSection(
                title: 'Client Info',
                children: [
                  CustomTextField(
                    label: 'Company Name',
                    hint: 'e.g. Logixhunt Pvt Ltd',
                    controller: _companyCtrl,
                    prefixIcon: const Icon(Icons.business_outlined, size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Contact Person',
                    hint: 'e.g. Rahul Sharma',
                    controller: _contactCtrl,
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Email',
                    hint: 'rahul@example.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.mail_outline, size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null; // optional
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Phone',
                    hint: '9876543210',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Renewal details ──────────────────────────────
              _FormSection(
                title: 'Renewal Info',
                children: [
                  CustomTextField(
                    label: 'Item Name',
                    hint: 'e.g. acme.com',
                    controller: _itemCtrl,
                    prefixIcon: const Icon(Icons.label_outline, size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Provider',
                    hint: 'e.g. GoDaddy',
                    controller: _providerCtrl,
                    prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Type chips ───────────────────────────────────
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
                        onSelected: (_) => setState(() => _selectedType = t),
                        labelStyle: TextStyle(
                          fontSize: AppTextSize.sm,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
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

              // ── Dates ────────────────────────────────────────
              _FormSection(
                title: 'Dates',
                children: [
                  CustomTextField(
                    label: 'Purchase Date',
                    controller: _purchaseDateCtrl,
                    readOnly: true,
                    onTap: () => _pickDate(
                      _purchaseDateCtrl,
                      (dt) => setState(() => _purchaseDate = dt),
                    ),
                    prefixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Select date' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    label: 'Renewal Date',
                    controller: _renewalDateCtrl,
                    readOnly: true,
                    onTap: () => _pickDate(
                      _renewalDateCtrl,
                      (dt) => setState(() => _renewalDate = dt),
                    ),
                    prefixIcon:
                        const Icon(Icons.event_available_outlined, size: 20),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Select date' : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Pricing ──────────────────────────────────────
              _FormSection(
                title: 'Pricing',
                children: [
                  CustomTextField(
                    label: 'Amount (₹)',
                    hint: '0',
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon:
                        const Icon(Icons.currency_rupee_rounded, size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    value: _selectedCycle,
                    decoration: InputDecoration(
                      labelText: 'Billing Cycle',
                      prefixIcon: const Icon(Icons.repeat_rounded, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    ),
                    // Show capitalised label, store lowercase value
                    items: _cycles
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                  '${c[0].toUpperCase()}${c.substring(1)}'),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCycle = v ?? 'yearly'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Reminder ─────────────────────────────────────
              _FormSection(
                title: 'Remind me before',
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _reminders.map((days) {
                      final selected = _reminderDays == days;
                      return ChoiceChip(
                        label: Text('$days days'),
                        selected: selected,
                        onSelected: (_) => setState(() => _reminderDays = days),
                        labelStyle: TextStyle(
                          fontSize: AppTextSize.sm,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
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

              // ── Notes ────────────────────────────────────────
              _FormSection(
                title: 'Notes',
                children: [
                  CustomTextField(
                    label: 'Notes (optional)',
                    hint: 'e.g. Main company domain',
                    controller: _notesCtrl,
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Auto-renew toggle ────────────────────────────
              Card(
                child: SwitchListTile(
                  title: const Text(
                    'Auto-renew',
                    style: TextStyle(
                        fontSize: AppTextSize.md, fontWeight: FontWeight.w600),
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

              // ── Save button ──────────────────────────────────
              _saving
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : PrimaryButton(label: 'Save Renewal', onPressed: _save),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Titled card section
// ─────────────────────────────────────────────────
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
