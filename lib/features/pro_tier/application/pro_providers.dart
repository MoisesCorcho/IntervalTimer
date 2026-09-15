import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/pro_tier/data/billing_repository.dart';
import 'package:interval_timer/features/pro_tier/data/fake_billing_driver.dart';
import 'package:interval_timer/features/pro_tier/data/revenue_cat_billing_driver.dart';
import 'package:interval_timer/features/pro_tier/data/revenue_cat_config.dart';
import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

/// Maximum number of custom workouts allowed in the Free tier.
const freeWorkoutsLimit = 3;

/// Injects the active [BillingRepository] implementation.
/// Defaults to [FakeBillingDriver] in debug/test or when RevenueCat API keys are absent.
/// Injects [RevenueCatBillingDriver] in release mode (or when FORCE_REVENUECAT is true) if configured.
final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  final prefs = ref.watch(preferencesRepositoryProvider);

  const forceRevenueCat = bool.fromEnvironment('FORCE_REVENUECAT', defaultValue: false);
  final shouldUseRevenueCat = (kReleaseMode || forceRevenueCat) && RevenueCatConfig.isConfigured;

  final BillingRepository driver;
  if (shouldUseRevenueCat) {
    driver = RevenueCatBillingDriver(preferencesRepository: prefs);
  } else {
    driver = FakeBillingDriver(preferencesRepository: prefs);
  }

  ref.onDispose(() => driver.dispose());
  return driver;
});

/// Reactive stream provider exposing whether the user has Pro entitlement.
final isProUserProvider = StreamProvider<bool>((ref) {
  final billingRepo = ref.watch(billingRepositoryProvider);
  return billingRepo.watchIsPro();
});

/// Fetches available subscription and lifetime packages.
final proProductsProvider = FutureProvider<List<ProductPackage>>((ref) async {
  final billingRepo = ref.watch(billingRepositoryProvider);
  return billingRepo.getAvailableProducts();
});

/// Counts total custom workouts created by the user.
final customWorkoutsCountProvider = Provider<int>((ref) {
  final workouts = ref.watch(workoutsListProvider).valueOrNull ?? [];
  return workouts.length;
});

/// Evaluates whether the user is authorized to create/duplicate a workout.
/// Pro users: always true.
/// Free users: true if customWorkoutsCount < freeWorkoutsLimit (3).
final canCreateWorkoutProvider = Provider<bool>((ref) {
  final isPro = ref.watch(isProUserProvider).valueOrNull ?? false;
  if (isPro) return true;

  final hasExtraSlot = ref.watch(isBenefitUnlockedProvider(RewardedBenefit.extraWorkoutSlot));
  final limit = hasExtraSlot ? (freeWorkoutsLimit + 1) : freeWorkoutsLimit;

  final count = ref.watch(customWorkoutsCountProvider);
  return count < limit;
});
