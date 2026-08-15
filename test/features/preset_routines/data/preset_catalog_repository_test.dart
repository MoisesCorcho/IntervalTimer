import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/preset_routines/data/asset_preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';

class FakeAssetBundle extends AssetBundle {
  final Map<String, String> assets;

  FakeAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) {
      return assets[key]!;
    }
    throw Exception('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

void main() {
  group('AssetPresetCatalogRepository', () {
    const validExercisesJson = '''
[
  {
    "id": "ex_pushups",
    "name": "Pushups",
    "category": "upperBody",
    "mediaType": "image",
    "mediaPath": "assets/media/exercises/ex_pushups.png",
    "steps": ["Step 1"],
    "tips": ["Tip 1"]
  }
]
''';

    const validPresetsJson = '''
[
  {
    "id": "preset_upper_15m",
    "title": "Upper Body Pump 15m",
    "description": "Enfoque en pecho.",
    "category": "upperBody",
    "difficulty": "advanced",
    "isFeatured": false,
    "restBetweenExercisesSeconds": 20,
    "exercises": [
      { "exerciseId": "ex_pushups", "sets": 4, "workSeconds": 40, "restSeconds": 15 }
    ]
  }
]
''';

    test('loads exercises successfully from AssetBundle', () async {
      final bundle = FakeAssetBundle({
        'assets/routines/exercises.json': validExercisesJson,
      });

      final repo = AssetPresetCatalogRepository(bundle: bundle);
      final exercises = await repo.getExercises();

      expect(exercises.length, equals(1));
      expect(exercises.first.id, equals('ex_pushups'));
      expect(exercises.first.name, equals('Pushups'));
      expect(exercises.first.category, equals(PresetCategory.upperBody));
    });

    test('getExerciseMap returns map indexed by exercise id', () async {
      final bundle = FakeAssetBundle({
        'assets/routines/exercises.json': validExercisesJson,
      });

      final repo = AssetPresetCatalogRepository(bundle: bundle);
      final map = await repo.getExerciseMap();

      expect(map.containsKey('ex_pushups'), isTrue);
      expect(map['ex_pushups']!.name, equals('Pushups'));
    });

    test('loads presets successfully from AssetBundle', () async {
      final bundle = FakeAssetBundle({
        'assets/routines/presets.json': validPresetsJson,
      });

      final repo = AssetPresetCatalogRepository(bundle: bundle);
      final presets = await repo.getPresets();

      expect(presets.length, equals(1));
      expect(presets.first.id, equals('preset_upper_15m'));
      expect(presets.first.title, equals('Upper Body Pump 15m'));
      expect(presets.first.difficulty, equals(DifficultyLevel.advanced));
    });

    test('getPresetById returns preset when present and null when missing', () async {
      final bundle = FakeAssetBundle({
        'assets/routines/presets.json': validPresetsJson,
      });

      final repo = AssetPresetCatalogRepository(bundle: bundle);
      final found = await repo.getPresetById('preset_upper_15m');
      final missing = await repo.getPresetById('non_existent');

      expect(found, isNotNull);
      expect(found!.id, equals('preset_upper_15m'));
      expect(missing, isNull);
    });

    test('throws PresetCatalogException when asset is missing or json corrupt', () async {
      final bundle = FakeAssetBundle({
        'assets/routines/exercises.json': 'invalid json {{{',
      });

      final repo = AssetPresetCatalogRepository(bundle: bundle);

      expect(
        () async => await repo.getExercises(),
        throwsA(isA<PresetCatalogException>()),
      );
    });

    test('resolveExercise returns synthetic exercise on missing key', () {
      final repo = AssetPresetCatalogRepository(bundle: FakeAssetBundle({}));
      final exercise = repo.resolveExercise('unknown_id', {});

      expect(exercise.id, equals('unknown_id'));
      expect(exercise.name, equals('Ejercicio Desconocido'));
    });
  });
}
