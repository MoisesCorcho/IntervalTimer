import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/workout.dart' as domain;
import 'package:interval_timer/data/models/workout_exercise.dart' as domain;

domain.Workout mapWorkoutRow(
  WorkoutRow row,
  List<WorkoutExerciseRow> exerciseRows,
) {
  return domain.Workout(
    id: row.id,
    name: row.name,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt, isUtc: true),
    exercises: exerciseRows
        .map(
          (e) => domain.WorkoutExercise(
            id: e.id,
            workoutId: e.workoutId,
            position: e.position,
            name: e.name,
            sets: e.sets,
            workSeconds: e.workSeconds,
            restSeconds: e.restSeconds,
            restAfterExerciseSeconds: e.restAfterExerciseSeconds,
          ),
        )
        .toList(),
  );
}