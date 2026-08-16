import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/preset_routines/application/preset_cloner_service.dart';
import 'package:interval_timer/features/preset_routines/data/asset_preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/data/preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

final presetCatalogRepositoryProvider = Provider<PresetCatalogRepository>((ref) {
  return AssetPresetCatalogRepository();
});

final presetCatalogProvider = FutureProvider<List<PresetRoutine>>((ref) async {
  final repo = ref.watch(presetCatalogRepositoryProvider);
  return repo.getPresets();
});

final exerciseMapProvider = FutureProvider<Map<String, Exercise>>((ref) async {
  final repo = ref.watch(presetCatalogRepositoryProvider);
  return repo.getExerciseMap();
});

final selectedPresetCategoryProvider = StateProvider<PresetCategory?>((ref) => null);

final selectedCategoryFilterProvider = selectedPresetCategoryProvider;

final filteredPresetsProvider = Provider<AsyncValue<List<PresetRoutine>>>((ref) {
  final catalogAsync = ref.watch(presetCatalogProvider);
  final filter = ref.watch(selectedPresetCategoryProvider);

  return catalogAsync.whenData((presets) {
    if (filter == null) return presets;
    return presets.where((p) => p.category == filter).toList();
  });
});

final presetDetailProvider = FutureProvider.family<PresetRoutine?, String>((ref, id) async {
  final repo = ref.watch(presetCatalogRepositoryProvider);
  return repo.getPresetById(id);
});

final presetClonerServiceProvider = Provider<PresetClonerService>((ref) {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final catalogRepo = ref.watch(presetCatalogRepositoryProvider);
  return PresetClonerService(
    workoutRepository: workoutRepo,
    catalogRepository: catalogRepo,
  );
});
