import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/repositories/body_measurement_repository.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement_weight_reader.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/stats/domain/weight_reader.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

final bodyMeasurementRepositoryProvider =
    Provider<BodyMeasurementRepository>((ref) {
  return BodyMeasurementRepository(ref.watch(databaseProvider));
});

/// All measurements ordered by localDate ascending (chart-friendly).
final bodyMeasurementsProvider =
    StreamProvider.autoDispose<List<BodyMeasurement>>((ref) {
  return ref.watch(bodyMeasurementRepositoryProvider).watchAll();
});

/// Latest weight in kg by max localDate, or null when empty.
final latestBodyWeightKgProvider = StreamProvider.autoDispose<double?>((ref) {
  return ref.watch(bodyMeasurementRepositoryProvider).watchLatestWeightKg();
});

/// F15 WeightReader for F12 override (see [weightReaderFromBodyTrackingProvider]).
final bodyMeasurementWeightReaderProvider = Provider<WeightReader>((ref) {
  final latest = ref.watch(latestBodyWeightKgProvider).asData?.value;
  return BodyMeasurementWeightReader(latestWeightKg: latest);
});

/// Display unit preference (kg/lb).
final bodyWeightUnitProvider =
    AsyncNotifierProvider<BodyWeightUnitController, BodyWeightUnit>(
  BodyWeightUnitController.new,
);

class BodyWeightUnitController extends AsyncNotifier<BodyWeightUnit> {
  @override
  Future<BodyWeightUnit> build() async {
    final raw =
        await ref.watch(preferencesRepositoryProvider).getBodyWeightUnit();
    return BodyWeightUnit.fromStorage(raw);
  }

  Future<void> setUnit(BodyWeightUnit unit) async {
    await ref
        .read(preferencesRepositoryProvider)
        .setBodyWeightUnit(unit.storageValue);
    state = AsyncData(unit);
  }
}

/// Form save / delete operations for body measurements.
class BodyMeasurementController {
  BodyMeasurementController(this._ref);

  final Ref _ref;

  BodyMeasurementRepository get _repo =>
      _ref.read(bodyMeasurementRepositoryProvider);

  Future<BodyMeasurement> save({
    required String localDate,
    required double weightKg,
    double? waistCm,
    double? armCm,
    double? legCm,
    String? existingId,
  }) {
    return _repo.upsertByLocalDate(
      localDate: localDate,
      weightKg: weightKg,
      waistCm: waistCm,
      armCm: armCm,
      legCm: legCm,
      existingId: existingId,
    );
  }

  Future<void> delete(String id) => _repo.delete(id);
}

final bodyMeasurementControllerProvider =
    Provider<BodyMeasurementController>((ref) {
  return BodyMeasurementController(ref);
});
