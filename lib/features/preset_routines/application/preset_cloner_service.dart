import 'package:interval_timer/data/models/routine.dart' as domain;
import 'package:interval_timer/data/repositories/routine_repository.dart';
import 'package:interval_timer/features/preset_routines/data/preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/preset_routines/domain/services/preset_routine_flattener.dart';

class PresetClonerService {
  final RoutineRepository routineRepository;
  final PresetCatalogRepository? catalogRepository;

  PresetClonerService({
    required this.routineRepository,
    this.catalogRepository,
  });

  Future<domain.Routine> clonePreset(
    PresetRoutine preset, {
    Map<String, Exercise>? exerciseMap,
  }) async {
    final Map<String, Exercise> map = exerciseMap ??
        await catalogRepository?.getExerciseMap() ??
        const {};

    final flattenedIntervals = PresetRoutineFlattener.flatten(
      preset: preset,
      exerciseMap: map,
    );

    final String name = '${preset.title} (Copia)';

    return routineRepository.clonePresetRoutine(
      name: name,
      intervals: flattenedIntervals,
      originId: preset.id,
    );
  }
}
