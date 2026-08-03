import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/body_measurement_repository.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement_weight_reader.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';

void main() {
  late AppDatabase db;
  late BodyMeasurementRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BodyMeasurementRepository(db);
  });

  tearDown(() async => db.close());

  group('BodyMeasurementRepository upsert (R4)', () {
    test('two saves same localDate leave one row with last weight', () async {
      await repo.upsertByLocalDate(
        localDate: '2026-08-01',
        weightKg: 70,
      );
      await repo.upsertByLocalDate(
        localDate: '2026-08-01',
        weightKg: 71.5,
        waistCm: 80,
      );

      final all = await repo.getAll();
      expect(all, hasLength(1));
      expect(all.first.weightKg, 71.5);
      expect(all.first.waistCm, 80);
      expect(all.first.localDate, '2026-08-01');
    });

    test('moving edit to occupied day upserts destination without duplicate',
        () async {
      final a = await repo.upsertByLocalDate(
        localDate: '2026-08-01',
        weightKg: 70,
      );
      await repo.upsertByLocalDate(
        localDate: '2026-08-02',
        weightKg: 72,
      );

      await repo.upsertByLocalDate(
        localDate: '2026-08-02',
        weightKg: 71,
        existingId: a.id,
      );

      final all = await repo.getAll();
      expect(all, hasLength(1));
      expect(all.first.localDate, '2026-08-02');
      expect(all.first.weightKg, 71);
    });
  });

  group('latest weight (R7)', () {
    test('uses max localDate not max weightKg', () async {
      await repo.upsertByLocalDate(localDate: '2026-07-01', weightKg: 90);
      await repo.upsertByLocalDate(localDate: '2026-08-01', weightKg: 75);

      final latest = await repo.latestByDate();
      expect(latest!.weightKg, 75);
      expect(latest.localDate, '2026-08-01');

      final reader = BodyMeasurementWeightReader(
        latestWeightKg: latest.weightKg,
      );
      expect(reader.read().isEstimated, isFalse);
      expect(reader.read().weightKg, 75);
    });

    test('delete last returns to estimated (R6, R7)', () async {
      final m = await repo.upsertByLocalDate(
        localDate: '2026-08-01',
        weightKg: 80,
      );
      await repo.delete(m.id);
      final latest = await repo.latestByDate();
      expect(latest, isNull);

      const reader = BodyMeasurementWeightReader();
      final reading = reader.read();
      expect(reading.weightKg, kDefaultWeightKg);
      expect(reading.isEstimated, isTrue);
    });
  });

  group('validation at repo boundary', () {
    test('rejects out of range weight', () async {
      expect(
        () => repo.upsertByLocalDate(localDate: '2026-08-01', weightKg: 19.9),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
