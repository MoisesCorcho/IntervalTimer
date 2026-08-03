import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement_weight_reader.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';

void main() {
  group('BodyMeasurementWeightReader (R1, R7)', () {
    test('without rows → 70 kg estimated', () {
      const reader = BodyMeasurementWeightReader();
      final reading = reader.read();
      expect(reading.weightKg, kDefaultWeightKg);
      expect(reading.isEstimated, isTrue);
    });

    test('with latest kg → not estimated', () {
      const reader = BodyMeasurementWeightReader(latestWeightKg: 82.5);
      final reading = reader.read();
      expect(reading.weightKg, 82.5);
      expect(reading.isEstimated, isFalse);
    });
  });
}
