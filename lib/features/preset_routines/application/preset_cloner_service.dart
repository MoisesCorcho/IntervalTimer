import 'package:interval_timer/data/models/workout.dart' as domain;
import 'package:interval_timer/data/repositories/workout_repository.dart';
import 'package:interval_timer/features/preset_routines/data/preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';

class PresetClonerService {
  final WorkoutRepository workoutRepository;
  final PresetCatalogRepository? catalogRepository;

  PresetClonerService({
    required this.workoutRepository,
    this.catalogRepository,
  });

  Future<domain.Workout> clonePreset(
    PresetRoutine preset, {
    Map<String, Exercise>? exerciseMap,
  }) async {
    final Map<String, Exercise> map = exerciseMap ??
        await catalogRepository?.getExerciseMap() ??
        const {};

    final exerciseDrafts = <WorkoutExerciseDraft>[];

    for (final ref in preset.exercises) {
      final exercise = map[ref.exerciseId];
      final name = exercise?.name ?? ref.exerciseId;
      exerciseDrafts.add(
        WorkoutExerciseDraft(
          name: name,
          sets: ref.sets,
          workSeconds: ref.workSeconds,
          restSeconds: ref.restSeconds,
          restAfterExerciseSeconds: preset.restBetweenExercisesSeconds,
        ),
      );
    }

    final String name = '${preset.title} (Copia)';

    return workoutRepository.createWorkoutWithExercises(
      name: name,
      exercises: exerciseDrafts,
      rounds: 1,
    );
  }
}
