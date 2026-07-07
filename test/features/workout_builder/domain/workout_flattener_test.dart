import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/data/models/workout_exercise.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_flattener.dart';
import 'package:uuid/uuid.dart';

const _workColor = 0xFF4CAF50;
const _restColor = 0xFF2196F3;

Workout _workoutWithExercises(List<WorkoutExercise> exercises) {
  return Workout(
    id: 'workout-1',
    name: 'Test',
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
    exercises: exercises,
  );
}

void main() {
  group('flattenWorkout', () {
    test('happy path: 1 exercise 3 sets 40s/20s → 5 intervals', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-1',
          workoutId: 'workout-1',
          position: 0,
          name: 'Push-ups',
          sets: 3,
          workSeconds: 40,
          restSeconds: 20,
        ),
      ]);

      final result = flattenWorkout(
        workout,
        workColorArgb: _workColor,
        restColorArgb: _restColor,
        uuid: const Uuid(),
      );

      expect(result.length, 5);
      expect(result[0].name, 'Push-ups');
      expect(result[0].durationSeconds, 40);
      expect(result[0].type, IntervalType.work);
      expect(result[1].name, 'Descanso');
      expect(result[1].durationSeconds, 20);
      expect(result[1].type, IntervalType.rest);
      expect(result[4].name, 'Push-ups');
      expect(result[4].type, IntervalType.work);
    });

    test('sets=1 produces only work interval', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-1',
          workoutId: 'workout-1',
          position: 0,
          name: 'Plank',
          sets: 1,
          workSeconds: 60,
          restSeconds: 30,
        ),
      ]);

      final result = flattenWorkout(
        workout,
        workColorArgb: AppTheme.workColor.toARGB32(),
        restColorArgb: AppTheme.restColor.toARGB32(),
      );

      expect(result.length, 1);
      expect(result.first.type, IntervalType.work);
    });

    test('restSeconds=0 omits rest intervals', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-1',
          workoutId: 'workout-1',
          position: 0,
          name: 'Burpees',
          sets: 3,
          workSeconds: 30,
          restSeconds: 0,
        ),
      ]);

      final result = flattenWorkout(
        workout,
        workColorArgb: _workColor,
        restColorArgb: _restColor,
      );

      expect(result.length, 3);
      expect(result.every((i) => i.type == IntervalType.work), isTrue);
    });

    test('two exercises maintains order', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-1',
          workoutId: 'workout-1',
          position: 0,
          name: 'First',
          sets: 2,
          workSeconds: 10,
          restSeconds: 5,
        ),
        const WorkoutExercise(
          id: 'ex-2',
          workoutId: 'workout-1',
          position: 1,
          name: 'Second',
          sets: 1,
          workSeconds: 20,
          restSeconds: 0,
        ),
      ]);

      final result = flattenWorkout(
        workout,
        workColorArgb: _workColor,
        restColorArgb: _restColor,
      );

      expect(result.length, 4);
      expect(result[0].name, 'First');
      expect(result[2].name, 'First');
      expect(result[3].name, 'Second');
    });
  });
}