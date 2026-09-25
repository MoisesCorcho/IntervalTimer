import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/body_measurement_repository.dart';
import 'package:interval_timer/features/body_tracking/application/body_tracking_providers.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

void main() {
  late AppDatabase db;
  late BodyMeasurementRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BodyMeasurementRepository(db);
  });

  tearDown(() async => db.close());

  Future<ProviderContainer> createInitializedContainer({required bool isPro}) async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        bodyMeasurementRepositoryProvider.overrideWithValue(repo),
        isProUserProvider.overrideWith((ref) => Stream.value(isPro)),
      ],
    );
    container.listen(isProUserProvider, (_, __) {});
    container.listen(bodyMeasurementsProvider, (_, __) {});
    await container.read(isProUserProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return container;
  }

  Future<void> seedMeasurements(int count) async {
    for (int i = 1; i <= count; i++) {
      final day = i.toString().padLeft(2, '0');
      await repo.upsertByLocalDate(
        localDate: '2026-08-$day',
        weightKg: 70.0 + i,
        waistCm: 80.0 + i,
        armCm: 35.0 + i,
        legCm: 55.0 + i,
      );
    }
  }

  group('visibleBodyMeasurementsProvider', () {
    test('when Free user has <= 5 measurements, returns all of them', () async {
      await seedMeasurements(3);
      final container = await createInitializedContainer(isPro: false);
      addTearDown(container.dispose);

      // Listen to initialize stream
      container.listen(bodyMeasurementsProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final visible = container.read(visibleBodyMeasurementsProvider).valueOrNull;
      expect(visible, isNotNull);
      expect(visible!.length, 3);
      expect(visible.first.localDate, '2026-08-01');
      expect(visible.last.localDate, '2026-08-03');
    });

    test('when Free user has 7 measurements, returns only last 5', () async {
      await seedMeasurements(7);
      final container = await createInitializedContainer(isPro: false);
      addTearDown(container.dispose);

      container.listen(bodyMeasurementsProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final visible = container.read(visibleBodyMeasurementsProvider).valueOrNull;
      expect(visible, isNotNull);
      expect(visible!.length, 5);
      expect(visible.first.localDate, '2026-08-03');
      expect(visible.last.localDate, '2026-08-07');
    });

    test('when Pro user has 7 measurements, returns all 7', () async {
      await seedMeasurements(7);
      final container = await createInitializedContainer(isPro: true);
      addTearDown(container.dispose);

      container.listen(bodyMeasurementsProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final visible = container.read(visibleBodyMeasurementsProvider).valueOrNull;
      expect(visible, isNotNull);
      expect(visible!.length, 7);
      expect(visible.first.localDate, '2026-08-01');
      expect(visible.last.localDate, '2026-08-07');
    });
  });

  group('hiddenMeasurementsCountProvider', () {
    test('returns 0 when Free user has <= 5 measurements', () async {
      await seedMeasurements(4);
      final container = await createInitializedContainer(isPro: false);
      addTearDown(container.dispose);

      container.listen(bodyMeasurementsProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(container.read(hiddenMeasurementsCountProvider), 0);
    });

    test('returns count - 5 when Free user has 8 measurements', () async {
      await seedMeasurements(8);
      final container = await createInitializedContainer(isPro: false);
      addTearDown(container.dispose);

      container.listen(bodyMeasurementsProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(container.read(hiddenMeasurementsCountProvider), 3);
    });

    test('returns 0 when Pro user has 8 measurements', () async {
      await seedMeasurements(8);
      final container = await createInitializedContainer(isPro: true);
      addTearDown(container.dispose);

      container.listen(bodyMeasurementsProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(container.read(hiddenMeasurementsCountProvider), 0);
    });
  });

  group('BodyMeasurementController save freemium anti-bypass', () {
    test('sanitizes body measures to null on new entry when user is Free', () async {
      final container = await createInitializedContainer(isPro: false);
      addTearDown(container.dispose);

      final controller = container.read(bodyMeasurementControllerProvider);
      final saved = await controller.save(
        localDate: '2026-08-10',
        weightKg: 75.0,
        waistCm: 82.0,
        armCm: 36.0,
        legCm: 56.0,
      );

      expect(saved.weightKg, 75.0);
      expect(saved.waistCm, isNull);
      expect(saved.armCm, isNull);
      expect(saved.legCm, isNull);
    });

    test('preserves existing body measures on edit when user is Free', () async {
      // Seed an existing measurement with measures from when user was Pro
      final initial = await repo.upsertByLocalDate(
        localDate: '2026-08-10',
        weightKg: 75.0,
        waistCm: 82.0,
        armCm: 36.0,
        legCm: 56.0,
      );

      final container = await createInitializedContainer(isPro: false);
      addTearDown(container.dispose);

      final controller = container.read(bodyMeasurementControllerProvider);
      // Free user attempts to update weight and modify waist to 90.0
      final updated = await controller.save(
        localDate: '2026-08-10',
        weightKg: 74.0,
        waistCm: 90.0,
        existingId: initial.id,
      );

      expect(updated.weightKg, 74.0);
      // Waist remains preserved from initial (82.0), not updated to 90.0
      expect(updated.waistCm, 82.0);
      expect(updated.armCm, 36.0);
      expect(updated.legCm, 56.0);
    });

    test('persists body measures on new entry when user is Pro', () async {
      final container = await createInitializedContainer(isPro: true);
      addTearDown(container.dispose);

      final controller = container.read(bodyMeasurementControllerProvider);
      final saved = await controller.save(
        localDate: '2026-08-10',
        weightKg: 75.0,
        waistCm: 82.0,
        armCm: 36.0,
        legCm: 56.0,
      );

      expect(saved.weightKg, 75.0);
      expect(saved.waistCm, 82.0);
      expect(saved.armCm, 36.0);
      expect(saved.legCm, 56.0);
    });
  });

  group('Rewarded pass bodyTrackingPass support (Modelo B)', () {
    test('when Free user has active bodyTrackingPass and 7 measurements, returns all 7', () async {
      await seedMeasurements(7);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          bodyMeasurementRepositoryProvider.overrideWithValue(repo),
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
          isBenefitUnlockedProvider(RewardedBenefit.bodyTrackingPass).overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      container.listen(bodyMeasurementsProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final visible = container.read(visibleBodyMeasurementsProvider).valueOrNull;
      expect(visible, isNotNull);
      expect(visible!.length, 7);
      expect(container.read(hiddenMeasurementsCountProvider), 0);
    });

    test('persists body measures on new entry when user is Free with active bodyTrackingPass', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          bodyMeasurementRepositoryProvider.overrideWithValue(repo),
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
          isBenefitUnlockedProvider(RewardedBenefit.bodyTrackingPass).overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(bodyMeasurementControllerProvider);
      final saved = await controller.save(
        localDate: '2026-08-10',
        weightKg: 75.0,
        waistCm: 82.0,
        armCm: 36.0,
        legCm: 56.0,
      );

      expect(saved.weightKg, 75.0);
      expect(saved.waistCm, 82.0);
      expect(saved.armCm, 36.0);
      expect(saved.legCm, 56.0);
    });

    test('when bodyTrackingPass expires, dynamically falls back to last 5 without losing data in DB', () async {
      await seedMeasurements(7);
      // Pass is now inactive (expired or false)
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          bodyMeasurementRepositoryProvider.overrideWithValue(repo),
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
          isBenefitUnlockedProvider(RewardedBenefit.bodyTrackingPass).overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      container.listen(bodyMeasurementsProvider, (_, __) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final visible = container.read(visibleBodyMeasurementsProvider).valueOrNull;
      expect(visible, isNotNull);
      expect(visible!.length, 5);
      expect(container.read(hiddenMeasurementsCountProvider), 2);

      // Verify ZERO DATA LOSS in database: all 7 records still exist in repo
      final allInDb = await repo.getAll();
      expect(allInDb.length, 7);
    });
  });
}

