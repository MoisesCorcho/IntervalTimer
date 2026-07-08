import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/data/repositories/workout_repository.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_editor_controller.dart';
import 'package:interval_timer/features/workout_builder/application/workouts_list_controller.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepository(ref.watch(databaseProvider));
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(ref.watch(databaseProvider));
});

final workoutsListProvider =
    AsyncNotifierProvider<WorkoutsListController, List<Workout>>(
  WorkoutsListController.new,
);

final workoutEditorControllerProvider =
    AsyncNotifierProviderFamily<WorkoutEditorController, Workout, String>(
  WorkoutEditorController.new,
);

final activeWorkoutIdProvider =
    AsyncNotifierProvider<ActiveWorkoutIdController, String?>(
  ActiveWorkoutIdController.new,
);

class ActiveWorkoutIdController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() {
    return ref.watch(preferencesRepositoryProvider).getActiveWorkoutId();
  }

  Future<void> setActiveWorkoutId(String? workoutId) async {
    await ref.read(preferencesRepositoryProvider).setActiveWorkoutId(workoutId);
    state = AsyncData(workoutId);
  }
}