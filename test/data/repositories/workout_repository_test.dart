import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/workout_repository.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = WorkoutRepository(db);
  });

  tearDown(() async => db.close());

  group('WorkoutRepository', () {
    test('create workout and add/edit/delete/reorder exercises', () async {
      final workout = await repo.createWorkout('Leg day');
      expect(workout.name, 'Leg day');
      expect(workout.exercises, isEmpty);

      final ex1 = await repo.addExercise(
        workoutId: workout.id,
        name: 'Squats',
        sets: 3,
        workSeconds: 40,
        restSeconds: 20,
        restAfterExerciseSeconds: 60,
      );
      final ex2 = await repo.addExercise(
        workoutId: workout.id,
        name: 'Lunges',
        sets: 2,
        workSeconds: 30,
        restSeconds: 10,
        restAfterExerciseSeconds: 0,
      );

      final loaded = await repo.getWorkout(workout.id);
      expect(loaded!.exercises.length, 2);
      expect(loaded.exercises[0].name, 'Squats');
      expect(loaded.exercises[0].restAfterExerciseSeconds, 60);
      expect(loaded.exercises[1].name, 'Lunges');
      expect(loaded.exercises[1].restAfterExerciseSeconds, 0);

      await repo.updateExercise(
        ex1.copyWith(
          name: 'Deep squats',
          sets: 4,
          restAfterExerciseSeconds: 90,
        ),
      );
      final updated = await repo.getWorkout(workout.id);
      expect(updated!.exercises.first.name, 'Deep squats');
      expect(updated.exercises.first.sets, 4);
      expect(updated.exercises.first.restAfterExerciseSeconds, 90);

      await repo.reorderExercises(workout.id, [ex2.id, ex1.id]);
      final reordered = await repo.getWorkout(workout.id);
      expect(reordered!.exercises.first.name, 'Lunges');

      await repo.deleteExercise(workout.id, ex2.id);
      final afterDelete = await repo.getWorkout(workout.id);
      expect(afterDelete!.exercises.length, 1);
      expect(afterDelete.exercises.first.position, 0);
    });

    test('duplicate workout uses Copia de prefix and copies exercises', () async {
      final workout = await repo.createWorkout('Upper');
      await repo.addExercise(
        workoutId: workout.id,
        name: 'Rows',
        sets: 2,
        workSeconds: 30,
        restSeconds: 15,
        restAfterExerciseSeconds: 45,
      );

      final copy = await repo.duplicateWorkout(workout.id);
      expect(copy.name, 'Copia de Upper');
      expect(copy.id, isNot(workout.id));
      expect(copy.exercises.length, 1);
      expect(copy.exercises.first.id, isNot(workout.id));
      expect(copy.exercises.first.name, 'Rows');
      expect(copy.exercises.first.restSeconds, 15);
      expect(copy.exercises.first.restAfterExerciseSeconds, 45);
    });

    test('duplicate resolves numeric suffix on name conflict', () async {
      final original = await repo.createWorkout('Cardio');
      await repo.createWorkout('Copia de Cardio');

      final copy = await repo.duplicateWorkout(original.id);
      expect(copy.name, 'Copia de Cardio (2)');
    });

    test('addExercise defaults restAfterExerciseSeconds when provided as 0',
        () async {
      final workout = await repo.createWorkout('Default rest');
      final ex = await repo.addExercise(
        workoutId: workout.id,
        name: 'Plank',
        sets: 1,
        workSeconds: 60,
        restSeconds: 0,
        restAfterExerciseSeconds: 0,
      );

      expect(ex.restAfterExerciseSeconds, 0);
      final loaded = await repo.getWorkout(workout.id);
      expect(loaded!.exercises.first.restAfterExerciseSeconds, 0);
    });

    test('create workout defaults rounds to 1', () async {
      final workout = await repo.createWorkout('Rounds default');
      expect(workout.rounds, 1);
      final loaded = await repo.getWorkout(workout.id);
      expect(loaded!.rounds, 1);
    });

    test('updateWorkoutRounds persists clamped value', () async {
      final workout = await repo.createWorkout('Rounds update');
      await repo.updateWorkoutRounds(workout.id, 4);
      expect((await repo.getWorkout(workout.id))!.rounds, 4);

      await repo.updateWorkoutRounds(workout.id, 0);
      expect((await repo.getWorkout(workout.id))!.rounds, 1);

      await repo.updateWorkoutRounds(workout.id, 150);
      expect((await repo.getWorkout(workout.id))!.rounds, 99);
    });

    test('duplicate workout copies rounds', () async {
      final workout = await repo.createWorkout('With rounds');
      await repo.updateWorkoutRounds(workout.id, 5);
      await repo.addExercise(
        workoutId: workout.id,
        name: 'Rows',
        sets: 2,
        workSeconds: 30,
        restSeconds: 10,
        restAfterExerciseSeconds: 0,
      );

      final copy = await repo.duplicateWorkout(workout.id);
      expect(copy.rounds, 5);
      expect(copy.exercises.length, 1);
    });

    test('createWorkoutWithExercises inserts workout and exercises atomically', () async {
      final created = await repo.createWorkoutWithExercises(
        name: 'Atomic Workout',
        exercises: const [
          WorkoutExerciseDraft(
            name: 'Pushups',
            sets: 3,
            workSeconds: 30,
            restSeconds: 15,
            restAfterExerciseSeconds: 30,
          ),
          WorkoutExerciseDraft(
            name: 'Pullups',
            sets: 4,
            workSeconds: 25,
            restSeconds: 20,
            restAfterExerciseSeconds: 45,
          ),
        ],
        rounds: 2,
      );

      expect(created.name, 'Atomic Workout');
      expect(created.rounds, 2);
      expect(created.exercises.length, 2);
      expect(created.exercises[0].name, 'Pushups');
      expect(created.exercises[0].position, 0);
      expect(created.exercises[1].name, 'Pullups');
      expect(created.exercises[1].position, 1);
    });
  });
}
