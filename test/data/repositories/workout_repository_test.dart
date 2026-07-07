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
      );
      final ex2 = await repo.addExercise(
        workoutId: workout.id,
        name: 'Lunges',
        sets: 2,
        workSeconds: 30,
        restSeconds: 10,
      );

      final loaded = await repo.getWorkout(workout.id);
      expect(loaded!.exercises.length, 2);
      expect(loaded.exercises[0].name, 'Squats');
      expect(loaded.exercises[1].name, 'Lunges');

      await repo.updateExercise(
        ex1.copyWith(name: 'Deep squats', sets: 4),
      );
      final updated = await repo.getWorkout(workout.id);
      expect(updated!.exercises.first.name, 'Deep squats');
      expect(updated.exercises.first.sets, 4);

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
      );

      final copy = await repo.duplicateWorkout(workout.id);
      expect(copy.name, 'Copia de Upper');
      expect(copy.id, isNot(workout.id));
      expect(copy.exercises.length, 1);
      expect(copy.exercises.first.id, isNot(workout.id));
      expect(copy.exercises.first.name, 'Rows');
    });

    test('duplicate resolves numeric suffix on name conflict', () async {
      final original = await repo.createWorkout('Cardio');
      await repo.createWorkout('Copia de Cardio');

      final copy = await repo.duplicateWorkout(original.id);
      expect(copy.name, 'Copia de Cardio (2)');
    });
  });
}