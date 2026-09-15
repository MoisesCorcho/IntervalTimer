import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/data/repositories/workout_repository.dart';
import 'package:interval_timer/features/pro_tier/application/paywall_controller.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/data/billing_repository.dart';
import 'package:interval_timer/features/pro_tier/data/fake_billing_driver.dart';
import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/pro_tier/domain/purchase_result.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late WorkoutRepository workoutRepo;
  late FakeBillingDriver driver;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    workoutRepo = WorkoutRepository(db);
    driver = FakeBillingDriver(preferencesRepository: prefs);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        preferencesRepositoryProvider.overrideWithValue(prefs),
        workoutRepositoryProvider.overrideWithValue(workoutRepo),
        billingRepositoryProvider.overrideWithValue(driver),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('Pro Providers & Anti-Bypass (F06)', () {
    test('isProUserProvider emits initial false and updates on purchase (R1, R6)', () async {
      // Keep alive listener so stream provider stays active
      container.listen(isProUserProvider, (_, __) {});
      expect(await container.read(isProUserProvider.future), isFalse);

      await driver.toggleMockPro(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(container.read(isProUserProvider).value, isTrue);
    });

    test('canCreateWorkoutProvider allows up to 3 workouts in Free and blocks 4th (R2, R3, R15)', () async {
      container.listen(workoutsListProvider, (_, __) {});
      container.listen(isProUserProvider, (_, __) {});
      await container.read(workoutsListProvider.future);
      await container.read(isProUserProvider.future);

      // 0 workouts
      expect(container.read(canCreateWorkoutProvider), isTrue);

      // Create 1
      await workoutRepo.createWorkout('W1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(canCreateWorkoutProvider), isTrue);

      // Create 2
      await workoutRepo.createWorkout('W2');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(canCreateWorkoutProvider), isTrue);

      // Create 3
      await workoutRepo.createWorkout('W3');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(canCreateWorkoutProvider), isFalse);

      // When upgraded to Pro, limit is lifted
      await driver.toggleMockPro(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(canCreateWorkoutProvider), isTrue);
    });

    test('canCreateWorkoutProvider preserves workouts and blocks only creation on downgrade (R16)', () async {
      container.listen(workoutsListProvider, (_, __) {});
      container.listen(isProUserProvider, (_, __) {});

      // Pro user creates 5 workouts
      await driver.toggleMockPro(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      for (var i = 1; i <= 5; i++) {
        await workoutRepo.createWorkout('Workout $i');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect((await workoutRepo.watchWorkouts().first).length, 5);

      // User downgrades to Free
      await driver.toggleMockPro(false);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // All 5 workouts remain intact and can be retrieved
      expect((await workoutRepo.watchWorkouts().first).length, 5);

      // But creating a 6th workout is blocked
      expect(container.read(canCreateWorkoutProvider), isFalse);
    });
  });

  group('PaywallController (F06)', () {
    test('purchase delegates to billing driver and updates state (R6)', () async {
      final controller = container.read(paywallControllerProvider.notifier);
      final products = await container.read(proProductsProvider.future);
      final annual = products.firstWhere((p) => p.period == BillingPeriod.annual);

      final result = await controller.purchase(annual);
      expect(result.status, PurchaseStatus.success);
      expect(await prefs.isProUser(), isTrue);
    });

    test('purchase handles cancellation without altering Pro state (R11)', () async {
      driver.simulateNextCancellation = true;
      final controller = container.read(paywallControllerProvider.notifier);
      final products = await container.read(proProductsProvider.future);

      final result = await controller.purchase(products.first);
      expect(result.status, PurchaseStatus.cancelled);
      expect(await prefs.isProUser(), isFalse);
    });

    test('restorePurchases restores previous purchase (R7, R12)', () async {
      driver.hasPriorPurchase = true;
      final controller = container.read(paywallControllerProvider.notifier);

      final result = await controller.restorePurchases();
      expect(result.status, PurchaseStatus.success);
      expect(await prefs.isProUser(), isTrue);
    });
  });
}
