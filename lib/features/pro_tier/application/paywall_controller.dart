import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/pro_tier/domain/purchase_result.dart';

/// Controller orchestrating purchase and restore flows in the paywall modal.
class PaywallController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial idle state
  }

  /// Initiates a purchase flow for the specified [package].
  Future<PurchaseResult> purchase(ProductPackage package) async {
    state = const AsyncValue.loading();
    final billingRepo = ref.read(billingRepositoryProvider);
    final result = await billingRepo.purchase(package);
    if (result.status == PurchaseStatus.error) {
      state = AsyncValue.error(result.errorMessage ?? 'Purchase failed', StackTrace.current);
    } else {
      state = const AsyncValue.data(null);
    }
    return result;
  }

  /// Restores prior purchases across device/store account reinstalls.
  Future<PurchaseResult> restorePurchases() async {
    state = const AsyncValue.loading();
    final billingRepo = ref.read(billingRepositoryProvider);
    final result = await billingRepo.restorePurchases();
    if (result.status == PurchaseStatus.error) {
      state = AsyncValue.error(result.errorMessage ?? 'Restore failed', StackTrace.current);
    } else {
      state = const AsyncValue.data(null);
    }
    return result;
  }
}

/// Provider exposing [PaywallController] lifecycle.
final paywallControllerProvider =
    AutoDisposeAsyncNotifierProvider<PaywallController, void>(
  PaywallController.new,
);
