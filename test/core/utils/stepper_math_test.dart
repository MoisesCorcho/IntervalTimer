import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/utils/stepper_math.dart';

void main() {
  group('clampStep happy path', () {
    test('+1 / -1 within number range', () {
      expect(
        clampStep(value: 5, delta: 1, min: 1, max: 99),
        6,
      );
      expect(
        clampStep(value: 5, delta: -1, min: 1, max: 99),
        4,
      );
    });

    test('+60 / -60 and +5 / -5 within duration range', () {
      expect(
        clampStep(value: 65, delta: 60, min: 1, max: 5999),
        125,
      );
      expect(
        clampStep(value: 65, delta: -60, min: 1, max: 5999),
        5,
      );
      expect(
        clampStep(value: 58, delta: 5, min: 1, max: 5999),
        63,
      );
      expect(
        clampStep(value: 58, delta: -5, min: 1, max: 5999),
        53,
      );
    });
  });

  group('clampStep and canApplyStep edges', () {
    test('does not leave min/max range', () {
      expect(
        clampStep(value: 1, delta: -1, min: 1, max: 99),
        1,
      );
      expect(
        clampStep(value: 99, delta: 1, min: 1, max: 99),
        99,
      );
      expect(
        clampStep(value: 5999, delta: 5, min: 0, max: 5999),
        5999,
      );
      expect(
        clampStep(value: 3, delta: -5, min: 1, max: 5999),
        1,
      );
    });

    test('canApplyStep is false at borders for full step', () {
      expect(
        canApplyStep(value: 1, delta: -1, min: 1, max: 99),
        isFalse,
      );
      expect(
        canApplyStep(value: 99, delta: 1, min: 1, max: 99),
        isFalse,
      );
      expect(
        canApplyStep(value: 1, delta: -5, min: 1, max: 5999),
        isFalse,
      );
      expect(
        canApplyStep(value: 3, delta: -5, min: 1, max: 5999),
        isFalse,
      );
      expect(
        canApplyStep(value: 5999, delta: 5, min: 0, max: 5999),
        isFalse,
      );
    });

    test('work min 1 vs rest min 0', () {
      expect(
        canApplyStep(value: 1, delta: -1, min: 1, max: 5999),
        isFalse,
      );
      expect(
        canApplyStep(value: 0, delta: -5, min: 0, max: 5999),
        isFalse,
      );
      expect(
        canApplyStep(value: 0, delta: 5, min: 0, max: 5999),
        isTrue,
      );
      expect(
        clampStep(value: 0, delta: 5, min: 0, max: 5999),
        5,
      );
    });
  });
}
