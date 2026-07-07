import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      await repo.updateWorkoutName(arg, name.trim());
      return (await repo.getWorkout(arg))!;
    });
  }

  Future<bool> addExercise({
    required String name,
    required int sets,
    required int workSeconds,
    required int restSeconds,
  }) async {
    if (!canEdit) return false;
    if (_hasValidationErrors(
      name: name,
      sets: sets,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
    )) {
      return false;
    }

    return _persist(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.addExercise(
        workoutId: arg,
        name: name.trim(),
        sets: sets,
        workSeconds: workSeconds,
        restSeconds: restSeconds,
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
    )) {
      return false;
    }

    return _persist(() async {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.updateExercise(exercise);
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

  Future<bool> _persist(Future<Workout> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }

  bool _hasValidationErrors({
    required String name,
    required int sets,
    required int workSeconds,
    required int restSeconds,
  }) {
    return WorkoutValidators.validateExerciseName(name) != null ||
        WorkoutValidators.validateSets(sets) != null ||
        WorkoutValidators.validateWorkSeconds(workSeconds) != null ||
        WorkoutValidators.validateRestSeconds(restSeconds) != null;
  }
}