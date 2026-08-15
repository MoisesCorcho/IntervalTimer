import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';

abstract class PresetCatalogRepository {
  Future<List<PresetRoutine>> getPresets();
  Future<List<Exercise>> getExercises();
  Future<Map<String, Exercise>> getExerciseMap();
  Future<PresetRoutine?> getPresetById(String id);
}
