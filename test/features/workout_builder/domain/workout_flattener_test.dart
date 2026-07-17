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
      expect(result[0].name, 'PUSH-UPS');
      expect(result[0].durationSeconds, 40);
      expect(result[0].type, IntervalType.work);
      expect(result[1].name, 'DESCANSO');
      expect(result[1].durationSeconds, 20);
      expect(result[1].type, IntervalType.rest);
      expect(result[4].name, 'PUSH-UPS');
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
      expect(result[0].name, 'FIRST');
      expect(result[2].name, 'FIRST');
      expect(result[3].name, 'SECOND');
    });

    test('multi-set + final: W R W R W + rest F when not last', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-a',
          workoutId: 'workout-1',
          position: 0,
          name: 'A',
          sets: 3,
          workSeconds: 30,
          restSeconds: 10,
          restAfterExerciseSeconds: 60,
        ),
        const WorkoutExercise(
          id: 'ex-b',
          workoutId: 'workout-1',
          position: 1,
          name: 'B',
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

      expect(result.length, 7);
      expect(result[0].type, IntervalType.work);
      expect(result[1].type, IntervalType.rest);
      expect(result[1].name, 'DESCANSO');
      expect(result[1].durationSeconds, 10);
      expect(result[2].type, IntervalType.work);
      expect(result[3].type, IntervalType.rest);
      expect(result[3].durationSeconds, 10);
      expect(result[4].type, IntervalType.work);
      expect(result[5].type, IntervalType.rest);
      expect(result[5].name, 'DESCANSO FINAL');
      expect(result[5].durationSeconds, 60);
      expect(result[6].name, 'B'); // single letter, already upper
      expect(result[6].type, IntervalType.work);
    });

    test('sets=1 + next: work A, final rest, work B (scenario A)', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-a',
          workoutId: 'workout-1',
          position: 0,
          name: 'A',
          sets: 1,
          workSeconds: 40,
          restSeconds: 20,
          restAfterExerciseSeconds: 90,
        ),
        const WorkoutExercise(
          id: 'ex-b',
          workoutId: 'workout-1',
          position: 1,
          name: 'B',
          sets: 1,
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
      expect(result[0].name, 'A');
      expect(result[0].durationSeconds, 40);
      expect(result[0].type, IntervalType.work);
      expect(result[1].name, 'DESCANSO FINAL');
      expect(result[1].durationSeconds, 90);
      expect(result[1].type, IntervalType.rest);
      expect(result[2].name, 'B');
      expect(result[2].durationSeconds, 30);
      expect(result[2].type, IntervalType.work);
    });

    test('final=0 omits inter-exercise rest (scenario C)', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-a',
          workoutId: 'workout-1',
          position: 0,
          name: 'A',
          sets: 2,
          workSeconds: 30,
          restSeconds: 15,
          restAfterExerciseSeconds: 0,
        ),
        const WorkoutExercise(
          id: 'ex-b',
          workoutId: 'workout-1',
          position: 1,
          name: 'B',
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
      expect(result[0].type, IntervalType.work);
      expect(result[1].durationSeconds, 15);
      expect(result[1].name, 'DESCANSO');
      expect(result[2].type, IntervalType.work);
      expect(result[3].name, 'B');
      expect(
        result.where((i) => i.name == 'DESCANSO FINAL'),
        isEmpty,
      );
    });

    test('last exercise ignores final rest (scenario D)', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-1',
          workoutId: 'workout-1',
          position: 0,
          name: 'Solo',
          sets: 2,
          workSeconds: 30,
          restSeconds: 10,
          restAfterExerciseSeconds: 120,
        ),
      ]);

      final result = flattenWorkout(
        workout,
        workColorArgb: _workColor,
        restColorArgb: _restColor,
      );

      expect(result.length, 3);
      expect(result[0].type, IntervalType.work);
      expect(result[1].name, 'DESCANSO');
      expect(result[2].type, IntervalType.work);
      expect(
        result.where((i) => i.name == 'DESCANSO FINAL'),
        isEmpty,
      );
    });

    test('chain A/B/C emits finals on A and B only (scenario E)', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-a',
          workoutId: 'workout-1',
          position: 0,
          name: 'A',
          sets: 3,
          workSeconds: 20,
          restSeconds: 20,
          restAfterExerciseSeconds: 45,
        ),
        const WorkoutExercise(
          id: 'ex-b',
          workoutId: 'workout-1',
          position: 1,
          name: 'B',
          sets: 2,
          workSeconds: 15,
          restSeconds: 10,
          restAfterExerciseSeconds: 30,
        ),
        const WorkoutExercise(
          id: 'ex-c',
          workoutId: 'workout-1',
          position: 2,
          name: 'C',
          sets: 1,
          workSeconds: 10,
          restSeconds: 5,
          restAfterExerciseSeconds: 99,
        ),
      ]);

      final result = flattenWorkout(
        workout,
        workColorArgb: _workColor,
        restColorArgb: _restColor,
      );

      // A: W R W R W + F45 = 6; B: W R W + F30 = 4; C: W = 1 → 11
      expect(result.length, 11);

      final finalRests =
          result.where((i) => i.name == 'DESCANSO FINAL').toList();
      expect(finalRests.length, 2);
      expect(finalRests[0].durationSeconds, 45);
      expect(finalRests[1].durationSeconds, 30);

      expect(result.last.name, 'C');
      expect(result.last.type, IntervalType.work);
    });

    test('single multi-set exercise: between-set rests, no final', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-1',
          workoutId: 'workout-1',
          position: 0,
          name: 'Solo',
          sets: 3,
          workSeconds: 40,
          restSeconds: 20,
          restAfterExerciseSeconds: 90,
        ),
      ]);

      final result = flattenWorkout(
        workout,
        workColorArgb: _workColor,
        restColorArgb: _restColor,
      );

      expect(result.length, 5);
      expect(
        result.where((i) => i.name == 'DESCANSO FINAL'),
        isEmpty,
      );
      expect(result.where((i) => i.name == 'DESCANSO').length, 2);
    });

    test('rounds=1 leaves round metadata null (legacy behavior)', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-1',
          workoutId: 'workout-1',
          position: 0,
          name: 'Push',
          sets: 2,
          workSeconds: 30,
          restSeconds: 10,
        ),
      ]).copyWith(rounds: 1);

      final result = flattenWorkout(
        workout,
        workColorArgb: _workColor,
        restColorArgb: _restColor,
      );

      expect(result.length, 3);
      expect(result.every((i) => i.roundIndex == null), isTrue);
      expect(result.every((i) => i.roundCount == null), isTrue);
    });

    test(
      'rounds=3 expands pass and emits last-exercise final rest between rounds',
      () {
        final workout = _workoutWithExercises([
          const WorkoutExercise(
            id: 'ex-a',
            workoutId: 'workout-1',
            position: 0,
            name: 'A',
            sets: 1,
            workSeconds: 20,
            restSeconds: 0,
            restAfterExerciseSeconds: 60,
          ),
          const WorkoutExercise(
            id: 'ex-b',
            workoutId: 'workout-1',
            position: 1,
            name: 'B',
            sets: 1,
            workSeconds: 15,
            restSeconds: 0,
            restAfterExerciseSeconds: 90,
          ),
        ]).copyWith(rounds: 3);

        final result = flattenWorkout(
          workout,
          workColorArgb: _workColor,
          restColorArgb: _restColor,
        );

        // Mid rounds: W(A) + F60 + W(B) + F90 = 4; last round: W(A)+F60+W(B)=3
        // → 4 + 4 + 3 = 11. F90 bridges rounds 1→2 and 2→3 only.
        expect(result.length, 11);
        expect(result.where((i) => i.name == 'DESCANSO FINAL').length, 5);
        expect(result.map((i) => i.name).toList(), [
          'A',
          'DESCANSO FINAL',
          'B',
          'DESCANSO FINAL',
          'A',
          'DESCANSO FINAL',
          'B',
          'DESCANSO FINAL',
          'A',
          'DESCANSO FINAL',
          'B',
        ]);
        expect(result[3].durationSeconds, 90);
        expect(result[3].roundIndex, 1);
        expect(result[7].durationSeconds, 90);
        expect(result[7].roundIndex, 2);
        expect(result.last.name, 'B');
        expect(result.last.type, IntervalType.work);

        expect(result[0].roundIndex, 1);
        expect(result[2].roundIndex, 1);
        expect(result[4].roundIndex, 2);
        expect(result[8].roundIndex, 3);
        expect(result.every((i) => i.roundCount == 3), isTrue);
      },
    );

    test(
      'rounds=2 + last exercise final rest > 0 bridges pass 1 and pass 2',
      () {
        final workout = _workoutWithExercises([
          const WorkoutExercise(
            id: 'ex-a',
            workoutId: 'workout-1',
            position: 0,
            name: 'A',
            sets: 1,
            workSeconds: 30,
            restSeconds: 0,
            restAfterExerciseSeconds: 0,
          ),
          const WorkoutExercise(
            id: 'ex-b',
            workoutId: 'workout-1',
            position: 1,
            name: 'B',
            sets: 1,
            workSeconds: 25,
            restSeconds: 0,
            restAfterExerciseSeconds: 45,
          ),
        ]).copyWith(rounds: 2);

        final result = flattenWorkout(
          workout,
          workColorArgb: _workColor,
          restColorArgb: _restColor,
        );

        // Pass1: W(A) W(B) F45; Pass2: W(A) W(B) — no trailing final rest
        expect(result.length, 5);
        expect(result.map((i) => i.name).toList(), [
          'A',
          'B',
          'DESCANSO FINAL',
          'A',
          'B',
        ]);
        expect(result[2].durationSeconds, 45);
        expect(result[2].type, IntervalType.rest);
        expect(result[2].roundIndex, 1);
        expect(result[3].roundIndex, 2);
        expect(result.last.type, IntervalType.work);
        expect(
          result.where((i) => i.name == 'DESCANSO FINAL').length,
          1,
        );
      },
    );

    test(
      'rounds=2 + last exercise final rest 0 has no gap between rounds',
      () {
        final workout = _workoutWithExercises([
          const WorkoutExercise(
            id: 'ex-a',
            workoutId: 'workout-1',
            position: 0,
            name: 'A',
            sets: 1,
            workSeconds: 20,
            restSeconds: 0,
            restAfterExerciseSeconds: 30,
          ),
          const WorkoutExercise(
            id: 'ex-b',
            workoutId: 'workout-1',
            position: 1,
            name: 'B',
            sets: 1,
            workSeconds: 15,
            restSeconds: 0,
            restAfterExerciseSeconds: 0,
          ),
        ]).copyWith(rounds: 2);

        final result = flattenWorkout(
          workout,
          workColorArgb: _workColor,
          restColorArgb: _restColor,
        );

        // Pass: W(A) F30 W(B); ×2; B final=0 so no bridge between rounds
        expect(result.length, 6);
        expect(result.map((i) => i.name).toList(), [
          'A',
          'DESCANSO FINAL',
          'B',
          'A',
          'DESCANSO FINAL',
          'B',
        ]);
        // Transition round1 B → round2 A is immediate (indices 2→3)
        expect(result[2].name, 'B');
        expect(result[2].type, IntervalType.work);
        expect(result[3].name, 'A');
        expect(result[3].type, IntervalType.work);
        expect(result.last.type, IntervalType.work);
      },
    );

    test(
      'after last round no trailing final rest even when last exercise has final > 0',
      () {
        final workout = _workoutWithExercises([
          const WorkoutExercise(
            id: 'ex-1',
            workoutId: 'workout-1',
            position: 0,
            name: 'Solo',
            sets: 1,
            workSeconds: 40,
            restSeconds: 0,
            restAfterExerciseSeconds: 120,
          ),
        ]).copyWith(rounds: 2);

        final result = flattenWorkout(
          workout,
          workColorArgb: _workColor,
          restColorArgb: _restColor,
        );

        // Round1: W + F120; Round2: W only
        expect(result.length, 3);
        expect(result.map((i) => i.name).toList(), [
          'SOLO',
          'DESCANSO FINAL',
          'SOLO',
        ]);
        expect(result[1].durationSeconds, 120);
        expect(result[1].roundIndex, 1);
        expect(result.last.type, IntervalType.work);
        expect(result.last.roundIndex, 2);
        expect(
          result.where((i) => i.name == 'DESCANSO FINAL').length,
          1,
        );
      },
    );

    test('rounds clamp: values below 1 behave as 1 pass', () {
      final workout = _workoutWithExercises([
        const WorkoutExercise(
          id: 'ex-1',
          workoutId: 'workout-1',
          position: 0,
          name: 'Solo',
          sets: 1,
          workSeconds: 10,
          restSeconds: 0,
        ),
      ]).copyWith(rounds: 0);

      final result = flattenWorkout(
        workout,
        workColorArgb: _workColor,
        restColorArgb: _restColor,
      );

      expect(result.length, 1);
      expect(result.first.roundIndex, isNull);
    });
  });
}
