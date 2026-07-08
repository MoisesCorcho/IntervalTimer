import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/local/mappers/workout_mapper.dart';
import 'package:interval_timer/data/models/workout.dart' as domain;
import 'package:interval_timer/data/models/workout_exercise.dart' as domain;
import 'package:uuid/uuid.dart';

class WorkoutRepository {
  WorkoutRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Stream<List<domain.Workout>> watchWorkouts() {
    return (_db.select(_db.workouts)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch()
        .asyncMap(_mapWorkoutRows);
  }

  Future<domain.Workout> createWorkout(String name) async {
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.workouts).insert(
          WorkoutRow(
            id: id,
            name: name,
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
    return domain.Workout(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
      exercises: const [],
    );
  }

  Future<domain.Workout?> getWorkout(String id) async {
    final row = await _db.getWorkoutRow(id);
    if (row == null) return null;
    final exercises = await _db.getWorkoutExerciseRows(id);
    return mapWorkoutRow(row, exercises);
  }

  Future<void> updateWorkoutName(String id, String name) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.workouts)..where((t) => t.id.equals(id))).write(
      WorkoutsCompanion(
        name: Value(name),
        updatedAt: Value(now.millisecondsSinceEpoch),
      ),
    );
  }

  Future<domain.WorkoutExercise> addExercise({
    required String workoutId,
    required String name,
    required int sets,
    required int workSeconds,
    required int restSeconds,
  }) async {
    final exercises = await _db.getWorkoutExerciseRows(workoutId);
    final position = exercises.length;
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _db.into(_db.workoutExercises).insert(
          WorkoutExerciseRow(
            id: id,
            workoutId: workoutId,
            position: position,
            name: name,
            sets: sets,
            workSeconds: workSeconds,
            restSeconds: restSeconds,
          ),
        );

    await (_db.update(_db.workouts)..where((t) => t.id.equals(workoutId)))
        .write(
      WorkoutsCompanion(updatedAt: Value(now.millisecondsSinceEpoch)),
    );

    return domain.WorkoutExercise(
      id: id,
      workoutId: workoutId,
      position: position,
      name: name,
      sets: sets,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
    );
  }

  Future<void> updateExercise(domain.WorkoutExercise exercise) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.workoutExercises)
          ..where((t) => t.id.equals(exercise.id)))
        .write(
      WorkoutExercisesCompanion(
        name: Value(exercise.name),
        sets: Value(exercise.sets),
        workSeconds: Value(exercise.workSeconds),
        restSeconds: Value(exercise.restSeconds),
      ),
    );

    await (_db.update(_db.workouts)
          ..where((t) => t.id.equals(exercise.workoutId)))
        .write(
      WorkoutsCompanion(updatedAt: Value(now.millisecondsSinceEpoch)),
    );
  }

  Future<void> deleteExercise(String workoutId, String exerciseId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.workoutExercises)
            ..where((t) => t.id.equals(exerciseId)))
          .go();

      final remaining = await _db.getWorkoutExerciseRows(workoutId);
      for (var i = 0; i < remaining.length; i++) {
        await (_db.update(_db.workoutExercises)
              ..where((t) => t.id.equals(remaining[i].id)))
            .write(WorkoutExercisesCompanion(position: Value(i)));
      }

      final now = DateTime.now().toUtc();
      await (_db.update(_db.workouts)..where((t) => t.id.equals(workoutId)))
          .write(
        WorkoutsCompanion(updatedAt: Value(now.millisecondsSinceEpoch)),
      );
    });
  }

  Future<void> reorderExercises(
    String workoutId,
    List<String> orderedIds,
  ) async {
    await _db.transaction(() async {
      // Two-phase update avoids UNIQUE (workout_id, position) collisions.
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.workoutExercises)
              ..where((t) => t.id.equals(orderedIds[i])))
            .write(WorkoutExercisesCompanion(position: Value(-(i + 1))));
      }
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.workoutExercises)
              ..where((t) => t.id.equals(orderedIds[i])))
            .write(WorkoutExercisesCompanion(position: Value(i)));
      }

      final now = DateTime.now().toUtc();
      await (_db.update(_db.workouts)..where((t) => t.id.equals(workoutId)))
          .write(
        WorkoutsCompanion(updatedAt: Value(now.millisecondsSinceEpoch)),
      );
    });
  }

  Future<domain.Workout> duplicateWorkout(String id) async {
    final source = await getWorkout(id);
    if (source == null) {
      throw StateError('Workout not found: $id');
    }

    final copyName = await _resolveDuplicateName(source.name);
    final now = DateTime.now().toUtc();
    final newId = _uuid.v4();

    await _db.transaction(() async {
      await _db.into(_db.workouts).insert(
            WorkoutRow(
              id: newId,
              name: copyName,
              createdAt: now.millisecondsSinceEpoch,
              updatedAt: now.millisecondsSinceEpoch,
            ),
          );

      for (final exercise in source.exercises) {
        await _db.into(_db.workoutExercises).insert(
              WorkoutExerciseRow(
                id: _uuid.v4(),
                workoutId: newId,
                position: exercise.position,
                name: exercise.name,
                sets: exercise.sets,
                workSeconds: exercise.workSeconds,
                restSeconds: exercise.restSeconds,
              ),
            );
      }
    });

    return (await getWorkout(newId))!;
  }

  Future<void> deleteWorkout(String id) async {
    await (_db.delete(_db.workouts)..where((t) => t.id.equals(id))).go();
  }

  Future<String> _resolveDuplicateName(String originalName) async {
    final base = 'Copia de $originalName';
    final all = await _db.getAllWorkoutRows();
    final names = all.map((w) => w.name).toSet();
    if (!names.contains(base)) return base;

    var suffix = 2;
    while (names.contains('$base ($suffix)')) {
      suffix++;
    }
    return '$base ($suffix)';
  }

  Future<List<domain.Workout>> _mapWorkoutRows(List<WorkoutRow> rows) async {
    final result = <domain.Workout>[];
    for (final row in rows) {
      final exercises = await _db.getWorkoutExerciseRows(row.id);
      result.add(mapWorkoutRow(row, exercises));
    }
    return result;
  }
}