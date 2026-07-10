import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/utils/name_format.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';

class WorkoutsListController extends AsyncNotifier<List<Workout>> {
  StreamSubscription<List<Workout>>? _subscription;

  @override
  Future<List<Workout>> build() async {
    final repo = ref.watch(workoutRepositoryProvider);

    final completer = Completer<List<Workout>>();
    _subscription?.cancel();
    _subscription = repo.watchWorkouts().listen(
      (workouts) {
        state = AsyncData(workouts);
        if (!completer.isCompleted) completer.complete(workouts);
      },
      onError: (Object e, StackTrace st) {
        state = AsyncError(e, st);
        if (!completer.isCompleted) completer.completeError(e, st);
      },
    );

    ref.onDispose(() => _subscription?.cancel());
    return completer.future;
  }

  Future<Workout?> createWorkout(String name) async {
    final error = WorkoutValidators.validateWorkoutName(name);
    if (error != null) return null;

    final repo = ref.read(workoutRepositoryProvider);
    return repo.createWorkout(formatDisplayName(name));
  }

  Future<Workout?> duplicateWorkout(String id) async {
    final repo = ref.read(workoutRepositoryProvider);
    try {
      return await repo.duplicateWorkout(id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteWorkout(String id) async {
    final repo = ref.read(workoutRepositoryProvider);
    try {
      await repo.deleteWorkout(id);
      final activeId = ref.read(activeWorkoutIdProvider).valueOrNull;
      if (activeId == id) {
        await ref.read(activeWorkoutIdProvider.notifier).setActiveWorkoutId(null);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}