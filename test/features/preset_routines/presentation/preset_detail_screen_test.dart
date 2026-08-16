import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/routine_repository.dart';
import 'package:interval_timer/features/favorites/application/favorite_providers.dart';
import 'package:interval_timer/features/preset_routines/application/preset_providers.dart';
import 'package:interval_timer/features/preset_routines/data/preset_catalog_repository.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_exercise_ref.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/preset_routines/presentation/screens/preset_detail_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

import '../../../helpers/fake_favorite_repository.dart';

class MockPresetCatalogRepository implements PresetCatalogRepository {
  final PresetRoutine preset;
  final Exercise exercise;

  MockPresetCatalogRepository({
    required this.preset,
    required this.exercise,
  });

  @override
  Future<List<Exercise>> getExercises() async => [exercise];

  @override
  Future<Map<String, Exercise>> getExerciseMap() async => {exercise.id: exercise};

  @override
  Future<List<PresetRoutine>> getPresets() async => [preset];

  @override
  Future<PresetRoutine?> getPresetById(String id) async {
    if (id == preset.id) return preset;
    return null;
  }
}

void main() {
  late AppDatabase db;
  late FakeFavoriteRepository favoriteRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    favoriteRepo = FakeFavoriteRepository();
  });

  tearDown(() async {
    favoriteRepo.dispose();
    await db.close();
  });

  const testExercise = Exercise(
    id: 'ex_burpees',
    name: 'Burpees',
    category: PresetCategory.hiit,
    mediaType: MediaType.image,
    mediaPath: 'assets/media/exercises/ex_burpees.png',
    steps: ['Paso 1 Burpee'],
    tips: ['Tip Burpee'],
  );

  const testPreset = PresetRoutine(
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

  testWidgets('PresetDetailScreen renders executive summary, exercise list, and FAB', (tester) async {
    final mockRepo = MockPresetCatalogRepository(
      preset: testPreset,
      exercise: testExercise,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          presetCatalogRepositoryProvider.overrideWithValue(mockRepo),
          databaseProvider.overrideWithValue(db),
          routineRepositoryProvider.overrideWithValue(RoutineRepository(db)),
          favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
        ],
        child: const MaterialApp(
          home: PresetDetailScreen(presetId: 'preset_hiit_15m'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify title and description
    expect(find.text('HIIT Quema Calórica 15m'), findsOneWidget);
    expect(find.text('Sesión de alta intensidad'), findsOneWidget);
    expect(find.text('Intermedio'), findsOneWidget);

    // Verify exercises section
    expect(find.text('Ejercicios de la Sesión'), findsOneWidget);
    expect(find.text('1. Burpees'), findsOneWidget);

    // Verify FAB "INICIAR ENTRENAMIENTO"
    expect(find.byKey(const Key('start_workout_fab')), findsOneWidget);

    // Verify Duplicar button
    expect(find.byKey(const Key('duplicate_routine_button')), findsOneWidget);

    // Tap exercise card to open technique sheet
    await tester.tap(find.text('1. Burpees'));
    await tester.pumpAndSettle();

    expect(find.text('Paso 1 Burpee'), findsOneWidget);
  });
}
