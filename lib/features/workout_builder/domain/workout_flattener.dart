import 'package:interval_timer/core/utils/name_format.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';
import 'package:uuid/uuid.dart';

/// Flattens a [Workout] into a linear sequence of [Interval]s for F01 execution.
///
/// When the session originates from F32, [SessionCompletedEvent.routineId] and
/// [SessionCancelledEvent.routineId] use the workout id as the origin reference.
///
/// F34 dual rest:
/// - [WorkoutExercise.restSeconds]: between sets of the same exercise
/// - [WorkoutExercise.restAfterExerciseSeconds]: after last set when there is a
///   following work segment — next exercise **within the same pass**, or the
///   first exercise of the **next round** when another global round follows.
///   Never emitted after the absolute last exercise of the session.
///
/// F32 global rounds ([Workout.rounds]):
/// - Expands one full pass `rounds` times (1–99).
/// - No invented rest between rounds: only the last exercise's existing
///   [WorkoutExercise.restAfterExerciseSeconds] (if > 0) bridges pass N → N+1.
/// - When rounds > 1, attaches ephemeral [Interval.roundIndex] / [Interval.roundCount].
List<Interval> flattenWorkout(
  Workout workout, {
  required int workColorArgb,
  required int restColorArgb,
  Uuid? uuid,
}) {
  final idGen = uuid ?? const Uuid();
  final rounds = workout.rounds.clamp(
    WorkoutValidators.minRounds,
    WorkoutValidators.maxRounds,
  );
  final result = <Interval>[];

  for (var round = 1; round <= rounds; round++) {
    final hasFollowingRound = round < rounds;
    final pass = _flattenSinglePass(
      workout,
      workColorArgb: workColorArgb,
      restColorArgb: restColorArgb,
      idGen: idGen,
      emitFinalRestOnLastExercise: hasFollowingRound,
    );

    if (rounds > 1) {
      for (final interval in pass) {
        result.add(
          interval.copyWith(
            roundIndex: round,
            roundCount: rounds,
          ),
        );
      }
    } else {
      result.addAll(pass);
    }
  }

  return result;
}

List<Interval> _flattenSinglePass(
  Workout workout, {
  required int workColorArgb,
  required int restColorArgb,
  required Uuid idGen,
  required bool emitFinalRestOnLastExercise,
}) {
  final result = <Interval>[];
  final exercises = workout.exercises;

  for (var i = 0; i < exercises.length; i++) {
    final exercise = exercises[i];
    final isLastExercise = i == exercises.length - 1;
    final hasFollowingWork =
        !isLastExercise || emitFinalRestOnLastExercise;

    for (var set = 1; set <= exercise.sets; set++) {
      result.add(
        Interval(
          id: idGen.v4(),
          name: formatDisplayName(exercise.name),
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
            name: formatDisplayName('Descanso'),
            durationSeconds: exercise.restSeconds,
            colorArgb: restColorArgb,
            type: IntervalType.rest,
          ),
        );
      }
    }

    if (hasFollowingWork && exercise.restAfterExerciseSeconds > 0) {
      result.add(
        Interval(
          id: idGen.v4(),
          name: formatDisplayName('Descanso final'),
          durationSeconds: exercise.restAfterExerciseSeconds,
          colorArgb: restColorArgb,
          type: IntervalType.rest,
        ),
      );
    }
  }

  return result;
}
