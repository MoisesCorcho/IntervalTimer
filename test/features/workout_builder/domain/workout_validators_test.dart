import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';

void main() {
  group('WorkoutValidators', () {
    test('rejects empty workout and exercise names', () {
      expect(WorkoutValidators.validateWorkoutName(''), isNotNull);
      expect(WorkoutValidators.validateExerciseName('   '), isNotNull);
    });

    test('rejects sets 0 or 100', () {
      expect(WorkoutValidators.validateSets(0), isNotNull);
      expect(WorkoutValidators.validateSets(100), isNotNull);
      expect(WorkoutValidators.validateSets(3), isNull);
    });

    test('rejects invalid work seconds', () {
      expect(WorkoutValidators.validateWorkSeconds(0), isNotNull);
      expect(WorkoutValidators.validateWorkSeconds(6000), isNotNull);
    });

    test('allows rest seconds at zero', () {
      expect(WorkoutValidators.validateRestSeconds(0), isNull);
    });

    test('rejects restAfterExerciseSeconds outside 0–5999', () {
      expect(
        WorkoutValidators.validateRestAfterExerciseSeconds(-1),
        isNotNull,
      );
      expect(
        WorkoutValidators.validateRestAfterExerciseSeconds(6000),
        isNotNull,
      );
      expect(WorkoutValidators.validateRestAfterExerciseSeconds(0), isNull);
      expect(WorkoutValidators.validateRestAfterExerciseSeconds(5999), isNull);
    });

    test('rejects rounds 0 or 100 and accepts 1–99', () {
      expect(WorkoutValidators.validateRounds(0), isNotNull);
      expect(WorkoutValidators.validateRounds(100), isNotNull);
      expect(WorkoutValidators.validateRounds(null), isNotNull);
      expect(WorkoutValidators.validateRounds(1), isNull);
      expect(WorkoutValidators.validateRounds(99), isNull);
    });

    test('clampRounds maps out-of-range to bounds', () {
      expect(WorkoutValidators.clampRounds(0), 1);
      expect(WorkoutValidators.clampRounds(-5), 1);
      expect(WorkoutValidators.clampRounds(100), 99);
      expect(WorkoutValidators.clampRounds(3), 3);
    });
  });
}