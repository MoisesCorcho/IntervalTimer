import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/repositories/body_measurement_repository.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement_weight_reader.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
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

/// Maximum number of historical measurements visible for Free tier.
const kFreeBodyMeasurementsLimit = 5;

/// Measurements filtered according to user's Pro subscription status.
/// When user is Free, only the latest [kFreeBodyMeasurementsLimit] records are returned.
final visibleBodyMeasurementsProvider =
    Provider.autoDispose<AsyncValue<List<BodyMeasurement>>>((ref) {
  final allAsync = ref.watch(bodyMeasurementsProvider);
  final isUnlocked =
      ref.watch(isBenefitUnlockedProvider(RewardedBenefit.bodyTrackingPass));

  return allAsync.whenData((list) {
    if (isUnlocked || list.length <= kFreeBodyMeasurementsLimit) {
      return list;
    }
    return list.sublist(list.length - kFreeBodyMeasurementsLimit);
  });
});

/// Number of older measurements preserved in database but hidden from Free tier.
final hiddenMeasurementsCountProvider = Provider.autoDispose<int>((ref) {
  final all = ref.watch(bodyMeasurementsProvider).valueOrNull ?? const [];
  final isUnlocked =
      ref.watch(isBenefitUnlockedProvider(RewardedBenefit.bodyTrackingPass));
  if (isUnlocked || all.length <= kFreeBodyMeasurementsLimit) {
    return 0;
  }
  return all.length - kFreeBodyMeasurementsLimit;
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
  }) async {
    final bool isUnlocked = _ref.read(
      isBenefitUnlockedProvider(RewardedBenefit.bodyTrackingPass),
    );
    double? effectiveWaist = waistCm;
    double? effectiveArm = armCm;
    double? effectiveLeg = legCm;

    if (!isUnlocked) {
      if (existingId != null) {
        final existing = await _repo.getById(existingId);
        effectiveWaist = existing?.waistCm;
        effectiveArm = existing?.armCm;
        effectiveLeg = existing?.legCm;
      } else {
        effectiveWaist = null;
        effectiveArm = null;
        effectiveLeg = null;
      }
    }

    return _repo.upsertByLocalDate(
      localDate: localDate,
      weightKg: weightKg,
      waistCm: effectiveWaist,
      armCm: effectiveArm,
      legCm: effectiveLeg,
      existingId: existingId,
    );
  }

  Future<void> delete(String id) => _repo.delete(id);
}

final bodyMeasurementControllerProvider =
    Provider<BodyMeasurementController>((ref) {
  return BodyMeasurementController(ref);
});
