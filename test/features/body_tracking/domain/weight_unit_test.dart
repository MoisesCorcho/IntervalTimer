import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';

void main() {
  group('BodyWeightUnit conversion (R8)', () {
    test('kg ↔ lb round-trip within 0.01 kg', () {
      const samples = [20.0, 70.0, 72.5, 100.0, 300.0];
      for (final kg in samples) {
        final lb = BodyWeightUnit.fromKg(kg, BodyWeightUnit.lb);
        final back = BodyWeightUnit.toKg(lb, BodyWeightUnit.lb);
        expect(back, closeTo(kg, 0.01));
      }
    });

    test('fromStorage defaults to kg', () {
      expect(BodyWeightUnit.fromStorage(null), BodyWeightUnit.kg);
      expect(BodyWeightUnit.fromStorage('lb'), BodyWeightUnit.lb);
      expect(BodyWeightUnit.fromStorage('kg'), BodyWeightUnit.kg);
      expect(BodyWeightUnit.fromStorage('nope'), BodyWeightUnit.kg);
    });

    test('formatDisplay one decimal', () {
      expect(
        BodyWeightUnit.formatDisplay(70, BodyWeightUnit.kg),
        '70.0',
      );
    });
  });
}
