import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:uuid/uuid.dart';

/// Flattens a [Workout] into a linear sequence of [Interval]s for F01 execution.
///
/// When the session originates from F32, [SessionCompletedEvent.routineId] and
/// [SessionCancelledEvent.routineId] use the workout id as the origin reference.
List<Interval> flattenWorkout(
  Workout workout, {
  required int workColorArgb,
  required int restColorArgb,
  Uuid? uuid,
}) {
  final idGen = uuid ?? const Uuid();
  final result = <Interval>[];

  for (final exercise in workout.exercises) {
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
  }

  return result;
}