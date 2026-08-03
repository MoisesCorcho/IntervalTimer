import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement.dart';
import 'package:uuid/uuid.dart';

class BodyMeasurementRepository {
  BodyMeasurementRepository(this._db, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Stream<List<BodyMeasurement>> watchAll() {
    return (_db.select(_db.bodyMeasurements)
          ..orderBy([(t) => OrderingTerm.asc(t.localDate)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  Future<List<BodyMeasurement>> getAll() async {
    final rows = await (_db.select(_db.bodyMeasurements)
          ..orderBy([(t) => OrderingTerm.asc(t.localDate)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<BodyMeasurement?> getById(String id) async {
    final row = await (_db.select(_db.bodyMeasurements)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<BodyMeasurement?> getByLocalDate(String localDate) async {
    final row = await (_db.select(_db.bodyMeasurements)
          ..where((t) => t.localDate.equals(localDate)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  /// Latest measurement by `localDate` descending (lexicographic = chronological).
  Future<BodyMeasurement?> latestByDate() async {
    final rows = await (_db.select(_db.bodyMeasurements)
          ..orderBy([
            (t) => OrderingTerm.desc(t.localDate),
            (t) => OrderingTerm.desc(t.updatedAt),
          ])
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Stream<BodyMeasurement?> watchLatestByDate() {
    return (_db.select(_db.bodyMeasurements)
          ..orderBy([
            (t) => OrderingTerm.desc(t.localDate),
            (t) => OrderingTerm.desc(t.updatedAt),
          ])
          ..limit(1))
        .watch()
        .map((rows) => rows.isEmpty ? null : _fromRow(rows.first));
  }

  Stream<double?> watchLatestWeightKg() {
    return watchLatestByDate().map((m) => m?.weightKg);
  }

  /// Upsert by [localDate]: one row per day (F15 R4).
  ///
  /// If [existingId] points to another day and [localDate] already has a row,
  /// the destination row is updated and the source row is deleted.
  Future<BodyMeasurement> upsertByLocalDate({
    required String localDate,
    required double weightKg,
    double? waistCm,
    double? armCm,
    double? legCm,
    String? existingId,
  }) async {
    final error = BodyMeasurementValidation.validateWeightKg(weightKg) ??
        BodyMeasurementValidation.validateMeasureCm(waistCm) ??
        BodyMeasurementValidation.validateMeasureCm(armCm) ??
        BodyMeasurementValidation.validateMeasureCm(legCm) ??
        BodyMeasurementValidation.validateLocalDate(localDate);
    if (error != null) {
      throw ArgumentError.value(error, 'validation', 'Invalid body measurement');
    }

    final now = DateTime.now().toUtc();
    final nowMs = now.millisecondsSinceEpoch;
    final atDate = await getByLocalDate(localDate);

    if (atDate != null) {
      final updated = atDate.copyWith(
        weightKg: weightKg,
        waistCm: waistCm,
        armCm: armCm,
        legCm: legCm,
        clearWaist: waistCm == null,
        clearArm: armCm == null,
        clearLeg: legCm == null,
        updatedAt: now,
      );
      await (_db.update(_db.bodyMeasurements)
            ..where((t) => t.id.equals(atDate.id)))
          .write(_toCompanion(updated));

      if (existingId != null && existingId != atDate.id) {
        await delete(existingId);
      }
      return updated;
    }

    if (existingId != null) {
      final old = await getById(existingId);
      if (old != null) {
        final moved = old.copyWith(
          localDate: localDate,
          weightKg: weightKg,
          waistCm: waistCm,
          armCm: armCm,
          legCm: legCm,
          clearWaist: waistCm == null,
          clearArm: armCm == null,
          clearLeg: legCm == null,
          updatedAt: now,
        );
        await (_db.update(_db.bodyMeasurements)
              ..where((t) => t.id.equals(existingId)))
            .write(_toCompanion(moved));
        return moved;
      }
    }

    final id = _uuid.v4();
    final created = BodyMeasurement(
      id: id,
      localDate: localDate,
      weightKg: weightKg,
      waistCm: waistCm,
      armCm: armCm,
      legCm: legCm,
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.bodyMeasurements).insert(
          BodyMeasurementsCompanion.insert(
            id: id,
            localDate: localDate,
            weightKg: weightKg,
            waistCm: Value(waistCm),
            armCm: Value(armCm),
            legCm: Value(legCm),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
    return created;
  }

  Future<void> update(BodyMeasurement measurement) async {
    final error = BodyMeasurementValidation.validate(measurement);
    if (error != null) {
      throw ArgumentError.value(error, 'validation', 'Invalid body measurement');
    }
    await (_db.update(_db.bodyMeasurements)
          ..where((t) => t.id.equals(measurement.id)))
        .write(_toCompanion(measurement));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.bodyMeasurements)..where((t) => t.id.equals(id)))
        .go();
  }

  BodyMeasurementsCompanion _toCompanion(BodyMeasurement m) {
    return BodyMeasurementsCompanion(
      id: Value(m.id),
      localDate: Value(m.localDate),
      weightKg: Value(m.weightKg),
      waistCm: Value(m.waistCm),
      armCm: Value(m.armCm),
      legCm: Value(m.legCm),
      createdAt: Value(m.createdAt.toUtc().millisecondsSinceEpoch),
      updatedAt: Value(m.updatedAt.toUtc().millisecondsSinceEpoch),
    );
  }

  BodyMeasurement _fromRow(BodyMeasurementRow row) {
    return BodyMeasurement(
      id: row.id,
      localDate: row.localDate,
      weightKg: row.weightKg,
      waistCm: row.waistCm,
      armCm: row.armCm,
      legCm: row.legCm,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(row.updatedAt, isUtc: true),
    );
  }
}
