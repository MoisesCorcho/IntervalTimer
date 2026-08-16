import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/preset_routines/application/preset_providers.dart';
import 'package:interval_timer/features/preset_routines/data/preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_exercise_ref.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';

class MockPresetCatalogRepository implements PresetCatalogRepository {
  final List<PresetRoutine> presets;
  final List<Exercise> exercises;

  MockPresetCatalogRepository({
    required this.presets,
    required this.exercises,
  });

  @override
  Future<List<Exercise>> getExercises() async => exercises;

  @override
  Future<Map<String, Exercise>> getExerciseMap() async {
    return {for (final e in exercises) e.id: e};
  }

  @override
  Future<List<PresetRoutine>> getPresets() async => presets;

  @override
  Future<PresetRoutine?> getPresetById(String id) async {
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  late ProviderContainer container;
  late MockPresetCatalogRepository mockRepo;

  const testPreset1 = PresetRoutine(
    id: 'preset_hiit_1',
    title: 'HIIT 1',
    description: 'HIIT routine',
    category: PresetCategory.hiit,
    difficulty: DifficultyLevel.intermediate,
    isFeatured: true,
    restBetweenExercisesSeconds: 15,
    exercises: [
      PresetExerciseRef(
        exerciseId: 'ex_burpees',
        sets: 3,
        workSeconds: 30,
        restSeconds: 10,
      ),
    ],
  );

  const testPreset2 = PresetRoutine(
    id: 'preset_core_1',
    title: 'Core 1',
    description: 'Core routine',
    category: PresetCategory.core,
    difficulty: DifficultyLevel.beginner,
    isFeatured: false,
    restBetweenExercisesSeconds: 10,
    exercises: [],
  );

  const testExercise = Exercise(
    id: 'ex_burpees',
    name: 'Burpees',
    category: PresetCategory.hiit,
    mediaType: MediaType.image,
    mediaPath: 'assets/media/exercises/ex_burpees.png',
    steps: ['Step 1'],
    tips: ['Tip 1'],
  );

  setUp(() {
    mockRepo = MockPresetCatalogRepository(
      presets: [testPreset1, testPreset2],
      exercises: [testExercise],
    );

    container = ProviderContainer(
      overrides: [
        presetCatalogRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('presetCatalogProvider loads presets list from repository', () async {
    final presets = await container.read(presetCatalogProvider.future);
    expect(presets.length, equals(2));
    expect(presets.first.id, equals('preset_hiit_1'));
  });

  test('exerciseMapProvider loads exercise map from repository', () async {
    final map = await container.read(exerciseMapProvider.future);
    expect(map.containsKey('ex_burpees'), isTrue);
    expect(map['ex_burpees']!.name, equals('Burpees'));
  });

  test('filteredPresetsProvider filters routines by selected category', () async {
    // Wait for catalog to load
    await container.read(presetCatalogProvider.future);

    // Initial state: no filter -> all presets returned
    final initialFiltered = container.read(filteredPresetsProvider).value;
    expect(initialFiltered?.length, equals(2));

    // Filter by HIIT category
    container.read(selectedPresetCategoryProvider.notifier).state = PresetCategory.hiit;
    final hiitFiltered = container.read(filteredPresetsProvider).value;
    expect(hiitFiltered?.length, equals(1));
    expect(hiitFiltered?.first.category, equals(PresetCategory.hiit));

    // Filter by Core category
    container.read(selectedPresetCategoryProvider.notifier).state = PresetCategory.core;
    final coreFiltered = container.read(filteredPresetsProvider).value;
    expect(coreFiltered?.length, equals(1));
    expect(coreFiltered?.first.category, equals(PresetCategory.core));
  });

  test('presetDetailProvider returns detail by id', () async {
    final preset = await container.read(presetDetailProvider('preset_hiit_1').future);
    expect(preset, isNotNull);
    expect(preset?.title, equals('HIIT 1'));

    final nullPreset = await container.read(presetDetailProvider('unknown_id').future);
    expect(nullPreset, isNull);
  });
}
