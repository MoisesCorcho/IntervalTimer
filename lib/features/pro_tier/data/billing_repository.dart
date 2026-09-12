import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/pro_tier/domain/purchase_result.dart';

/// Abstract Port for managing in-app purchases, entitlement querying,
/// and restoration decoupled from specific store SDKs.
abstract class BillingRepository {
  /// Checks whether the user currently has an active Pro entitlement.
  Future<bool> isPro();

  /// Reactive stream emitting Pro entitlement status changes.
  Stream<bool> watchIsPro();

  /// Fetches available purchase packages (subscriptions and lifetime).
  Future<List<ProductPackage>> getAvailableProducts();

  /// Initiates a purchase flow for the selected package.
  Future<PurchaseResult> purchase(ProductPackage package);

  /// Restores previous active purchases made on Google Play or App Store.
  Future<PurchaseResult> restorePurchases();

  /// Indicates whether the active driver is a developer simulation mock.
  bool get isMockDriver;

  /// Toggles mock Pro entitlement in real-time (debug environments only).
  Future<void> toggleMockPro(bool enable);
}
