import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:uuid/uuid.dart';

/// Flattens a [Workout] into a linear sequence of [Interval]s for F01 execution.
///
/// When the session originates from F32, [SessionCompletedEvent.routineId] and
/// [SessionCancelledEvent.routineId] use the workout id as the origin reference.
///
/// F34 dual rest:
/// - [WorkoutExercise.restSeconds]: between sets of the same exercise
/// - [WorkoutExercise.restAfterExerciseSeconds]: after last set if another
///   exercise follows (never on the last exercise of the workout)
List<Interval> flattenWorkout(
  Workout workout, {
  required int workColorArgb,
  required int restColorArgb,
  Uuid? uuid,
}) {
  final idGen = uuid ?? const Uuid();
  final result = <Interval>[];
  final exercises = workout.exercises;

  for (var i = 0; i < exercises.length; i++) {
    final exercise = exercises[i];
    final isLastExercise = i == exercises.length - 1;

    for (var set = 1; set <= exercise.sets; set++) {
      result.add(
        Interval(
          id: idGen.v4(),
          name: exercise.name,
          durationSeconds: exercise.workSeconds,
          colorArgb: workColorArgb,
          type: IntervalType.work,
        ),
      );

      final isLastSet = set == exercise.sets;
      if (!isLastSet && exercise.restSeconds > 0) {
        result.add(
          Interval(
            id: idGen.v4(),
            name: 'Descanso',
            durationSeconds: exercise.restSeconds,
            colorArgb: restColorArgb,
            type: IntervalType.rest,
          ),
        );
      }
    }

    if (!isLastExercise && exercise.restAfterExerciseSeconds > 0) {
      result.add(
        Interval(
          id: idGen.v4(),
          name: 'Descanso entre ejercicios',
          durationSeconds: exercise.restAfterExerciseSeconds,
          colorArgb: restColorArgb,
          type: IntervalType.rest,
        ),
      );
    }
  }

  return result;
}
