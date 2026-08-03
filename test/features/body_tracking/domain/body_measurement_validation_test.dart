import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement.dart';

void main() {
  group('BodyMeasurementValidation weight (R10)', () {
    test('rejects null, non-finite, ≤0', () {
      expect(BodyMeasurementValidation.validateWeightKg(null), 'weight_required');
      expect(BodyMeasurementValidation.validateWeightKg(double.nan), 'weight_invalid');
      expect(BodyMeasurementValidation.validateWeightKg(0), 'weight_invalid');
      expect(BodyMeasurementValidation.validateWeightKg(-1), 'weight_invalid');
    });

    test('accepts boundary 20 and 300 kg; rejects 19.9 and 300.1', () {
      expect(BodyMeasurementValidation.validateWeightKg(20), isNull);
      expect(BodyMeasurementValidation.validateWeightKg(300), isNull);
      expect(BodyMeasurementValidation.validateWeightKg(19.9), 'weight_range');
      expect(BodyMeasurementValidation.validateWeightKg(300.1), 'weight_range');
    });
  });

  group('BodyMeasurementValidation measures (R11)', () {
    test('null measure is OK; ≤0 and >300 rejected', () {
      expect(BodyMeasurementValidation.validateMeasureCm(null), isNull);
      expect(BodyMeasurementValidation.validateMeasureCm(80), isNull);
      expect(BodyMeasurementValidation.validateMeasureCm(0), 'measure_invalid');
      expect(BodyMeasurementValidation.validateMeasureCm(-1), 'measure_invalid');
      expect(BodyMeasurementValidation.validateMeasureCm(300.1), 'measure_range');
      expect(BodyMeasurementValidation.validateMeasureCm(300), isNull);
    });
  });

  group('BodyMeasurementValidation date (R11)', () {
    final now = DateTime(2026, 8, 3, 15, 30);

    test('today OK; future rejected', () {
      expect(
        BodyMeasurementValidation.validateLocalDate('2026-08-03', now: now),
        isNull,
      );
      expect(
        BodyMeasurementValidation.validateLocalDate('2026-08-04', now: now),
        'date_future',
      );
    });

    test('invalid format rejected', () {
      expect(
        BodyMeasurementValidation.validateLocalDate('not-a-date', now: now),
        'date_invalid',
      );
    });
  });
}
