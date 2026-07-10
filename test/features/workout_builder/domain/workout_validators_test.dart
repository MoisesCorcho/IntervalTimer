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
  });
}