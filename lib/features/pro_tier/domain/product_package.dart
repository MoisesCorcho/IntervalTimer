/// Billing recurrence period for In-App Purchase products.
enum BillingPeriod {
  monthly,
  annual,
  lifetime,
}

/// Inmutable domain entity describing a purchasable Pro Tier package.
class ProductPackage {
  const ProductPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.priceFormatted,
    required this.priceNumeric,
    required this.period,
    this.hasFreeTrial = false,
    this.discountPercentage,
  });

  final String id;
  final String title;
  final String description;
  final String priceFormatted;
  final double priceNumeric;
  final BillingPeriod period;
  final bool hasFreeTrial;
  final int? discountPercentage;
}
