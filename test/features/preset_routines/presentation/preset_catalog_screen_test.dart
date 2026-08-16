import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/favorites/application/favorite_providers.dart';
import 'package:interval_timer/features/preset_routines/application/preset_providers.dart';
import 'package:interval_timer/features/preset_routines/data/asset_preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/data/preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_exercise_ref.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/preset_routines/presentation/screens/preset_catalog_screen.dart';

import '../../../helpers/fake_favorite_repository.dart';

class MockPresetCatalogRepository implements PresetCatalogRepository {
  final List<PresetRoutine> presets;
  final bool shouldThrow;

  MockPresetCatalogRepository({
    this.presets = const [],
    this.shouldThrow = false,
  });

  @override
  Future<List<Exercise>> getExercises() async => [];

  @override
  Future<Map<String, Exercise>> getExerciseMap() async => {};

  @override
  Future<List<PresetRoutine>> getPresets() async {
    if (shouldThrow) {
      throw PresetCatalogException('Error test JSON corrupto');
    }
    return presets;
  }


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
  late FakeFavoriteRepository favoriteRepo;

  setUp(() {
    favoriteRepo = FakeFavoriteRepository();
  });

  tearDown(() {
    favoriteRepo.dispose();
  });

  const testPreset1 = PresetRoutine(
    id: 'preset_hiit_15m',
    title: 'HIIT Quema Calórica 15m',
    description: 'Sesión de alta intensidad',
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
    id: 'preset_abs_10m',
    title: 'Abs de Acero 10m',
    description: 'Fortalecimiento de abdomen',
    category: PresetCategory.core,
    difficulty: DifficultyLevel.beginner,
    isFeatured: false,
    restBetweenExercisesSeconds: 10,
    exercises: [],
  );

  testWidgets('PresetCatalogScreen renders featured carousel, category filter chips, and cards', (tester) async {
    final mockRepo = MockPresetCatalogRepository(presets: [testPreset1, testPreset2]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
          presetCatalogRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: PresetCatalogScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify featured section
    expect(find.text('Destacadas del Día'), findsOneWidget);
    expect(find.text('HIIT Quema Calórica 15m'), findsAtLeastNWidgets(1));

    // Verify Category Chips
    expect(find.text('Todos'), findsOneWidget);
    expect(find.byKey(const Key('category_chip_hiit')), findsOneWidget);
    expect(find.byKey(const Key('category_chip_core')), findsOneWidget);

    // Verify preset card
    expect(find.text('Abs de Acero 10m'), findsOneWidget);

    // Tap on Core chip to filter
    await tester.tap(find.byKey(const Key('category_chip_core')));
    await tester.pumpAndSettle();

    // Should show 1 filtered routine
    expect(find.text('Abdomen & Core (1)'), findsOneWidget);
    expect(find.text('Abs de Acero 10m'), findsOneWidget);
  });

  testWidgets('PresetCatalogScreen renders error widget and retry button on catalog error', (tester) async {
    final mockRepo = MockPresetCatalogRepository(shouldThrow: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
          presetCatalogRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: PresetCatalogScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('catalog_error_widget')), findsOneWidget);
    expect(find.byKey(const Key('catalog_retry_button')), findsOneWidget);
  });

  testWidgets('PresetCatalogScreen favorites filter displays empty state when no favorites', (tester) async {
    final mockRepo = MockPresetCatalogRepository(presets: [testPreset1, testPreset2]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
          presetCatalogRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: PresetCatalogScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on Favoritos filter chip
    await tester.tap(find.byKey(const Key('filter_chip_favorites')));
    await tester.pumpAndSettle();

    // Should show empty state message for favorites
    expect(find.text('No tienes rutinas preestablecidas favoritas.'), findsOneWidget);
  });
}

