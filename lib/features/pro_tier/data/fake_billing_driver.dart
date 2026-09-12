import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/pro_tier/data/billing_repository.dart';
import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/pro_tier/domain/purchase_result.dart';

/// In-memory and preference-backed mock implementation of [BillingRepository]
/// for deterministic testing and instant dev UI preview without store coupling.
class FakeBillingDriver implements BillingRepository {
  FakeBillingDriver({
    required PreferencesRepository preferencesRepository,
  }) : _prefs = preferencesRepository;

  final PreferencesRepository _prefs;

  bool simulateNextFailure = false;
  bool simulateNextCancellation = false;
  bool hasPriorPurchase = false;

  static const defaultProducts = <ProductPackage>[
    ProductPackage(
      id: 'interval_timer_pro_monthly',
      title: 'Mensual',
      description: 'Acceso completo renovable mes a mes',
      priceFormatted: '\$2.99',
      priceNumeric: 2.99,
      period: BillingPeriod.monthly,
      hasFreeTrial: false,
    ),
    ProductPackage(
      id: 'interval_timer_pro_annual',
      title: 'Anual',
      description: '7 días de prueba gratis, luego \$17.99 / año',
      priceFormatted: '\$17.99',
      priceNumeric: 17.99,
      period: BillingPeriod.annual,
      hasFreeTrial: true,
      discountPercentage: 50,
    ),
    ProductPackage(
      id: 'interval_timer_pro_lifetime',
      title: 'De por vida',
      description: 'Pago único. Acceso total para siempre.',
      priceFormatted: '\$29.99',
      priceNumeric: 29.99,
      period: BillingPeriod.lifetime,
      hasFreeTrial: false,
    ),
  ];

  @override
  bool get isMockDriver => true;

  @override
  Future<bool> isPro() => _prefs.isProUser();

  @override
  Stream<bool> watchIsPro() => _prefs.watchIsProUser();

  @override
  Future<List<ProductPackage>> getAvailableProducts() async {
    return defaultProducts;
  }

  @override
  Future<PurchaseResult> purchase(ProductPackage package) async {
    if (simulateNextCancellation) {
      simulateNextCancellation = false;
      return const PurchaseResult.cancelled();
    }

    if (simulateNextFailure) {
      simulateNextFailure = false;
      return const PurchaseResult.error('La transacción fue rechazada por el banco emisor.');
    }

    await _prefs.setIsProUser(true);
    hasPriorPurchase = true;
    return const PurchaseResult.success();
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    if (hasPriorPurchase) {
      await _prefs.setIsProUser(true);
      return const PurchaseResult.success();
    }

    return const PurchaseResult.error('No se encontraron suscripciones previas activas.');
  }

  @override
  Future<void> toggleMockPro(bool enable) async {
    await _prefs.setIsProUser(enable);
  }
}
