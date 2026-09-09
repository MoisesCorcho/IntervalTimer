import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:interval_timer/features/preset_routines/data/preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';

class PresetCatalogException implements Exception {
  final String message;
  final dynamic originalError;

  const PresetCatalogException(this.message, [this.originalError]);

  @override
  String toString() =>
      'PresetCatalogException: $message${originalError != null ? " ($originalError)" : ""}';
}

class AssetPresetCatalogRepository implements PresetCatalogRepository {
  final AssetBundle _bundle;
  final String? localeCode;
  final String exercisesPath;
  final String presetsPath;

  AssetPresetCatalogRepository({
    AssetBundle? bundle,
    this.localeCode,
    this.exercisesPath = 'assets/routines/exercises.json',
    this.presetsPath = 'assets/routines/presets.json',
  }) : _bundle = bundle ?? rootBundle;

  Future<String> _loadStringWithFallback(List<String> paths) async {
    for (final path in paths) {
      try {
        return await _bundle.loadString(path);
      } catch (_) {
        // try next fallback
      }
    }
    throw Exception('None of the paths could be loaded: ${paths.join(", ")}');
  }

  @override
  Future<List<Exercise>> getExercises() async {
    final candidatePaths = <String>[];
    if (localeCode != null && localeCode!.isNotEmpty) {
      candidatePaths.add('assets/routines/exercises_$localeCode.json');
    }
    candidatePaths.add('assets/routines/exercises_en.json');
    candidatePaths.add(exercisesPath);

    try {
      final String jsonString = await _loadStringWithFallback(candidatePaths);
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PresetCatalogException(
        'Error al cargar ejercicios desde ${candidatePaths.join(", ")}',
        e,
      );
    }
  }

  @override
  Future<Map<String, Exercise>> getExerciseMap() async {
    final exercises = await getExercises();
    return {for (final e in exercises) e.id: e};
  }

  @override
  Future<List<PresetRoutine>> getPresets() async {
    final candidatePaths = <String>[];
    if (localeCode != null && localeCode!.isNotEmpty) {
      candidatePaths.add('assets/routines/presets_$localeCode.json');
    }
    candidatePaths.add('assets/routines/presets_en.json');
    candidatePaths.add(presetsPath);

    try {
      final String jsonString = await _loadStringWithFallback(candidatePaths);
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => PresetRoutine.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw PresetCatalogException(
        'Error al cargar presets desde ${candidatePaths.join(", ")}',
        e,
      );
    }
  }

  @override
  Future<PresetRoutine?> getPresetById(String id) async {
    final presets = await getPresets();
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Helper defensivo para resolver ejercicios referenciados en un preset,
  /// retornando un ejercicio sintético fallback en caso de que no exista en el mapa.
  Exercise resolveExercise(
      String exerciseId, Map<String, Exercise> exerciseMap) {
    if (exerciseMap.containsKey(exerciseId)) {
      return exerciseMap[exerciseId]!;
    }
    return Exercise(
      id: exerciseId,
      name: 'Ejercicio Desconocido',
      category: PresetCategory.fullBody,
      mediaType: MediaType.image,
      mediaPath: 'assets/media/categories/cat_fullbody.png',
      steps: const ['Sigue el temporizador de intervalo.'],
      tips: const [],
    );
  }
}
