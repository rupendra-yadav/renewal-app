/// Possible states a renewal can be in.
enum RenewalStatus { active, dueSoon, expired }

/// Supported renewal types.
enum RenewalType { domain, server, ssl, hosting }

/// Core data model for a single renewal entry.
class Renewal {
  final String id;
  final String itemName;
  final String clientName;
  final String provider;
  final RenewalType type;
  final DateTime purchaseDate;
  final DateTime renewalDate;
  final double amount;
  final String billingCycle; // "Monthly" | "Yearly"
  final bool autoRenew;
  final List<int> reminderDays;
  final RenewalStatus status;

  const Renewal({
    required this.id,
    required this.itemName,
    required this.clientName,
    required this.provider,
    required this.type,
    required this.purchaseDate,
    required this.renewalDate,
    required this.amount,
    required this.billingCycle,
    required this.autoRenew,
    required this.reminderDays,
    required this.status,
  });

  String get typeLabel {
    switch (type) {
      case RenewalType.domain:
        return 'Domain';
      case RenewalType.server:
        return 'Server';
      case RenewalType.ssl:
        return 'SSL';
      case RenewalType.hosting:
        return 'Hosting';
    }
  }

  String get statusLabel {
    switch (status) {
      case RenewalStatus.active:
        return 'Active';
      case RenewalStatus.dueSoon:
        return 'Due soon';
      case RenewalStatus.expired:
        return 'Expired';
    }
  }
}

/// Static dummy dataset used across all screens.
abstract class DummyData {
  static final List<Renewal> renewals = [
    Renewal(
      id: '1',
      itemName: 'retailio.in',
      clientName: 'RetailIO Pvt Ltd',
      provider: 'GoDaddy',
      type: RenewalType.domain,
      purchaseDate: DateTime(2023, 6, 15),
      renewalDate: DateTime.now().add(const Duration(days: 2)),
      amount: 999,
      billingCycle: 'Yearly',
      autoRenew: false,
      reminderDays: [7, 15],
      status: RenewalStatus.expired,
    ),
    Renewal(
      id: '2',
      itemName: 'shopfast.com',
      clientName: 'ShopFast Inc.',
      provider: 'Namecheap',
      type: RenewalType.domain,
      purchaseDate: DateTime(2023, 3, 10),
      renewalDate: DateTime.now().add(const Duration(days: 5)),
      amount: 1499,
      billingCycle: 'Yearly',
      autoRenew: true,
      reminderDays: [7],
      status: RenewalStatus.expired,
    ),
    Renewal(
      id: '3',
      itemName: 'VPS Pro – 4GB',
      clientName: 'TechNova Solutions',
      provider: 'DigitalOcean',
      type: RenewalType.server,
      purchaseDate: DateTime(2024, 1, 1),
      renewalDate: DateTime.now().add(const Duration(days: 12)),
      amount: 3200,
      billingCycle: 'Monthly',
      autoRenew: true,
      reminderDays: [7, 15, 30],
      status: RenewalStatus.dueSoon,
    ),
    Renewal(
      id: '4',
      itemName: 'brandkart.in',
      clientName: 'BrandKart Agency',
      provider: 'BigRock',
      type: RenewalType.domain,
      purchaseDate: DateTime(2023, 9, 20),
      renewalDate: DateTime.now().add(const Duration(days: 18)),
      amount: 799,
      billingCycle: 'Yearly',
      autoRenew: false,
      reminderDays: [15],
      status: RenewalStatus.dueSoon,
    ),
    Renewal(
      id: '5',
      itemName: 'SSL Wildcard',
      clientName: 'RetailIO Pvt Ltd',
      provider: 'Comodo',
      type: RenewalType.ssl,
      purchaseDate: DateTime(2023, 7, 1),
      renewalDate: DateTime.now().add(const Duration(days: 25)),
      amount: 4500,
      billingCycle: 'Yearly',
      autoRenew: false,
      reminderDays: [30],
      status: RenewalStatus.dueSoon,
    ),
    Renewal(
      id: '6',
      itemName: 'cPanel Hosting – 10GB',
      clientName: 'DevStudio Labs',
      provider: 'Hostinger',
      type: RenewalType.hosting,
      purchaseDate: DateTime(2024, 2, 14),
      renewalDate: DateTime.now().add(const Duration(days: 60)),
      amount: 2200,
      billingCycle: 'Yearly',
      autoRenew: true,
      reminderDays: [7, 30],
      status: RenewalStatus.active,
    ),
    Renewal(
      id: '7',
      itemName: 'devstudio.io',
      clientName: 'DevStudio Labs',
      provider: 'GoDaddy',
      type: RenewalType.domain,
      purchaseDate: DateTime(2022, 5, 5),
      renewalDate: DateTime.now().add(const Duration(days: 90)),
      amount: 1299,
      billingCycle: 'Yearly',
      autoRenew: false,
      reminderDays: [15, 30],
      status: RenewalStatus.active,
    ),
    Renewal(
      id: '8',
      itemName: 'AWS EC2 – t3.medium',
      clientName: 'TechNova Solutions',
      provider: 'Amazon AWS',
      type: RenewalType.server,
      purchaseDate: DateTime(2024, 3, 1),
      renewalDate: DateTime.now().add(const Duration(days: 120)),
      amount: 8500,
      billingCycle: 'Monthly',
      autoRenew: true,
      reminderDays: [7],
      status: RenewalStatus.active,
    ),
    Renewal(
      id: '9',
      itemName: 'innovate360.com',
      clientName: 'Innovate360',
      provider: 'Namecheap',
      type: RenewalType.domain,
      purchaseDate: DateTime(2023, 11, 22),
      renewalDate: DateTime.now().add(const Duration(days: 150)),
      amount: 1100,
      billingCycle: 'Yearly',
      autoRenew: true,
      reminderDays: [30],
      status: RenewalStatus.active,
    ),
    Renewal(
      id: '10',
      itemName: 'SSL DV – Single',
      clientName: 'BrandKart Agency',
      provider: 'Let\'s Encrypt',
      type: RenewalType.ssl,
      purchaseDate: DateTime(2024, 4, 1),
      renewalDate: DateTime.now().add(const Duration(days: 200)),
      amount: 0,
      billingCycle: 'Yearly',
      autoRenew: true,
      reminderDays: [7],
      status: RenewalStatus.active,
    ),
    Renewal(
      id: '11',
      itemName: 'Shared Hosting Pro',
      clientName: 'ShopFast Inc.',
      provider: 'Hostgator',
      type: RenewalType.hosting,
      purchaseDate: DateTime(2023, 8, 8),
      renewalDate: DateTime.now().add(const Duration(days: 240)),
      amount: 3600,
      billingCycle: 'Yearly',
      autoRenew: false,
      reminderDays: [15],
      status: RenewalStatus.active,
    ),
    Renewal(
      id: '12',
      itemName: 'growthspark.in',
      clientName: 'GrowthSpark',
      provider: 'BigRock',
      type: RenewalType.domain,
      purchaseDate: DateTime(2022, 12, 30),
      renewalDate: DateTime.now().add(const Duration(days: 300)),
      amount: 850,
      billingCycle: 'Yearly',
      autoRenew: false,
      reminderDays: [30],
      status: RenewalStatus.active,
    ),
  ];

  /// Renewals expiring within 7 days (urgent).
  static List<Renewal> get urgentRenewals =>
      renewals.where((r) => r.status == RenewalStatus.expired).toList();

  /// Renewals due within 30 days.
  static List<Renewal> get dueSoonRenewals =>
      renewals.where((r) => r.status == RenewalStatus.dueSoon).toList();
}
