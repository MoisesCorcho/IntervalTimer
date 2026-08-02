import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/utils/name_format.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/data/models/workout_exercise.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';

class WorkoutEditorController extends FamilyAsyncNotifier<Workout, String> {
  @override
  Future<Workout> build(String workoutId) async {
    final repo = ref.watch(workoutRepositoryProvider);
    final workout = await repo.getWorkout(workoutId);
    if (workout == null) {
      throw StateError('Workout not found: $workoutId');
    }
    return workout;
  }

  bool get canEdit {
    final timerState = ref.read(timerControllerProvider);
    return timerState.status == TimerStatus.idle;
  }

  bool get canDeleteWorkout => canEdit;

  Future<bool> renameWorkout(String name) async {
    final error = WorkoutValidators.validateWorkoutName(name);
    if (error != null) return false;
    if (!canEdit) return false;

    return _persist(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.updateWorkoutName(arg, formatDisplayName(name));
      return (await repo.getWorkout(arg))!;
    });
  }

  Future<bool> updateRounds(int rounds) async {
    if (!canEdit) return false;
    final clamped = WorkoutValidators.clampRounds(rounds);
    if (WorkoutValidators.validateRounds(clamped) != null) return false;

    return _persist(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.updateWorkoutRounds(arg, clamped);
      return (await repo.getWorkout(arg))!;
    });
  }

  Future<bool> addExercise({
    required String name,
    required int sets,
    required int workSeconds,
    required int restSeconds,
    required int restAfterExerciseSeconds,
  }) async {
    if (!canEdit) return false;
    if (_hasValidationErrors(
      name: name,
      sets: sets,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
      restAfterExerciseSeconds: restAfterExerciseSeconds,
    )) {
      return false;
    }

    return _persist(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.addExercise(
        workoutId: arg,
        name: formatDisplayName(name),
        sets: sets,
        workSeconds: workSeconds,
        restSeconds: restSeconds,
        restAfterExerciseSeconds: restAfterExerciseSeconds,
      );
      return (await repo.getWorkout(arg))!;
    });
  }

  Future<bool> updateExercise(WorkoutExercise exercise) async {
    if (!canEdit) return false;
    if (_hasValidationErrors(
      name: exercise.name,
      sets: exercise.sets,
      workSeconds: exercise.workSeconds,
      restSeconds: exercise.restSeconds,
      restAfterExerciseSeconds: exercise.restAfterExerciseSeconds,
    )) {
      return false;
    }

    return _persist(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.updateExercise(
        exercise.copyWith(name: formatDisplayName(exercise.name)),
      );
      return (await repo.getWorkout(arg))!;
    });
  }

  Future<bool> deleteExercise(String exerciseId) async {
    if (!canEdit) return false;

    return _persist(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.deleteExercise(arg, exerciseId);
      return (await repo.getWorkout(arg))!;
    });
  }

  Future<bool> reorderExercises(List<String> orderedIds) async {
    if (!canEdit) return false;

    return _persist(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.reorderExercises(arg, orderedIds);
      return (await repo.getWorkout(arg))!;
    });
  }

  /// Persists a mutation without clearing previous [AsyncData].
  ///
  /// Mutations must not emit pure [AsyncLoading] — the editor UI remounts on
  /// loading-without-value and flickers a full-screen spinner on every save
  /// (rounds, reorder, rename, exercises).
  ///
  /// On success: [AsyncData] with the updated workout.
  /// On failure: previous state is kept so the form stays mounted; returns
  /// `false` for the screen snackbar/retry path.
  Future<bool> _persist(Future<Workout> Function() action) async {
    try {
      final result = await action();
      state = AsyncData(result);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _hasValidationErrors({
    required String name,
    required int sets,
    required int workSeconds,
    required int restSeconds,
    required int restAfterExerciseSeconds,
  }) {
    return WorkoutValidators.validateExerciseName(name) != null ||
        WorkoutValidators.validateSets(sets) != null ||
        WorkoutValidators.validateWorkSeconds(workSeconds) != null ||
        WorkoutValidators.validateRestSeconds(restSeconds) != null ||
        WorkoutValidators.validateRestAfterExerciseSeconds(
              restAfterExerciseSeconds,
            ) !=
            null;
  }
}
