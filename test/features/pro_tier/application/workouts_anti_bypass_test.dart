import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/data/repositories/workout_repository.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/data/temporary_pass_repository.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/data/fake_billing_driver.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late WorkoutRepository workoutRepo;
  late TemporaryPassRepository passRepo;
  late FakeBillingDriver driver;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    workoutRepo = WorkoutRepository(db);
    passRepo = TemporaryPassRepository(db, prefs);
    driver = FakeBillingDriver(preferencesRepository: prefs);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        preferencesRepositoryProvider.overrideWithValue(prefs),
        workoutRepositoryProvider.overrideWithValue(workoutRepo),
        temporaryPassRepositoryProvider.overrideWithValue(passRepo),
        billingRepositoryProvider.overrideWithValue(driver),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('Workouts Anti-Bypass & Concurrency Mutex (F06 - R2, R15, R18)', () {
    test('createWorkout allows up to 3 custom workouts in Free and blocks 4th (R2, R3, R15)', () async {
      container.listen(workoutsListProvider, (_, __) {});
      final controller = container.read(workoutsListProvider.notifier);

      // 1st workout
      final w1 = await controller.createWorkout('Workout 1');
      expect(w1, isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // 2nd workout
      final w2 = await controller.createWorkout('Workout 2');
      expect(w2, isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // 3rd workout
      final w3 = await controller.createWorkout('Workout 3');
      expect(w3, isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Total workouts in DB is 3
      expect((await workoutRepo.watchWorkouts().first).length, 3);
      expect(container.read(canCreateWorkoutProvider), isFalse);

      // 4th workout creation attempt in Free MUST be rejected
      final w4 = await controller.createWorkout('Workout 4');
      expect(w4, isNull);
      expect((await workoutRepo.watchWorkouts().first).length, 3);

      // Upgrading to Pro unlocks creation
      await driver.toggleMockPro(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(canCreateWorkoutProvider), isTrue);

      final w4Pro = await controller.createWorkout('Workout 4');
      expect(w4Pro, isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect((await workoutRepo.watchWorkouts().first).length, 4);
    });

    test('duplicateWorkout is blocked when user reaches 3 workouts in Free (R15)', () async {
      container.listen(workoutsListProvider, (_, __) {});
      final controller = container.read(workoutsListProvider.notifier);

      // Create 3 workouts
      final w1 = await controller.createWorkout('Routine A');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await controller.createWorkout('Routine B');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await controller.createWorkout('Routine C');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect((await workoutRepo.watchWorkouts().first).length, 3);

      // Duplication attempt in Free MUST be rejected
      final duplicated = await controller.duplicateWorkout(w1!.id);
      expect(duplicated, isNull);
      expect((await workoutRepo.watchWorkouts().first).length, 3);

      // Upgrading to Pro unlocks duplication
      await driver.toggleMockPro(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final dupPro = await controller.duplicateWorkout(w1.id);
      expect(dupPro, isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect((await workoutRepo.watchWorkouts().first).length, 4);
    });

    test('createWorkout allows 4th workout when extraWorkoutSlot pass is active and blocks 5th', () async {
      container.listen(workoutsListProvider, (_, __) {});
      final controller = container.read(workoutsListProvider.notifier);

      // Create 3 workouts
      await controller.createWorkout('W1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await controller.createWorkout('W2');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await controller.createWorkout('W3');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect((await workoutRepo.watchWorkouts().first).length, 3);
      expect(container.read(canCreateWorkoutProvider), isFalse);

      // 4th creation fails without pass
      expect(await controller.createWorkout('W4'), isNull);

      // Grant extraWorkoutSlot pass
      await passRepo.grantPass(
        benefit: RewardedBenefit.extraWorkoutSlot,
        duration: const Duration(hours: 24),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(canCreateWorkoutProvider), isTrue);

      // 4th workout creation SUCCEEDS with active pass
      final w4 = await controller.createWorkout('W4');
      expect(w4, isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect((await workoutRepo.watchWorkouts().first).length, 4);

      // 5th creation attempt MUST be blocked even with pass
      expect(container.read(canCreateWorkoutProvider), isFalse);
      final w5 = await controller.createWorkout('W5');
      expect(w5, isNull);
      expect((await workoutRepo.watchWorkouts().first).length, 4);
    });

    test('duplicateWorkout allows 4th workout when extraWorkoutSlot pass is active and blocks 5th', () async {
      container.listen(workoutsListProvider, (_, __) {});
      final controller = container.read(workoutsListProvider.notifier);

      final w1 = await controller.createWorkout('W1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await controller.createWorkout('W2');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await controller.createWorkout('W3');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect((await workoutRepo.watchWorkouts().first).length, 3);
      expect(container.read(canCreateWorkoutProvider), isFalse);

      // Duplication fails without pass
      expect(await controller.duplicateWorkout(w1!.id), isNull);

      // Grant extraWorkoutSlot pass
      await passRepo.grantPass(
        benefit: RewardedBenefit.extraWorkoutSlot,
        duration: const Duration(hours: 24),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(canCreateWorkoutProvider), isTrue);

      // 4th workout duplication SUCCEEDS with active pass
      final dup = await controller.duplicateWorkout(w1.id);
      expect(dup, isNotNull);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect((await workoutRepo.watchWorkouts().first).length, 4);

      // 5th duplication attempt MUST be blocked
      expect(container.read(canCreateWorkoutProvider), isFalse);
      final dup5 = await controller.duplicateWorkout(w1.id);
      expect(dup5, isNull);
      expect((await workoutRepo.watchWorkouts().first).length, 4);
    });
  });
}
