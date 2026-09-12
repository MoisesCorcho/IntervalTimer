import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/pro_tier/data/billing_repository.dart';
import 'package:interval_timer/features/pro_tier/data/fake_billing_driver.dart';
import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

/// Maximum number of custom workouts allowed in the Free tier.
const freeWorkoutsLimit = 3;

/// Injects the active [BillingRepository] implementation (defaults to [FakeBillingDriver]).
final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  final prefs = ref.watch(preferencesRepositoryProvider);
  return FakeBillingDriver(preferencesRepository: prefs);
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

  final count = ref.watch(customWorkoutsCountProvider);
  return count < freeWorkoutsLimit;
});
