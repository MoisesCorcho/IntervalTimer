import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/data/repositories/favorite_repository.dart';
import 'package:interval_timer/data/repositories/workout_repository.dart';
import 'package:interval_timer/features/favorites/application/favorite_providers.dart';
import 'package:interval_timer/features/preset_routines/application/preset_providers.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workouts_list_controller.dart';

class _StaticWorkoutsList extends WorkoutsListController {
  _StaticWorkoutsList(this.workouts);

  final List<Workout> workouts;

  @override
  Future<List<Workout>> build() async => workouts;
}

void main() {
  late AppDatabase db;
  late FavoriteRepository favoriteRepo;
  late WorkoutRepository workoutRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    favoriteRepo = DriftFavoriteRepository(db);
    workoutRepo = WorkoutRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Favorite Providers', () {
    test('isFavoriteProvider returns true for favorited id and false otherwise',
        () async {
      final container = ProviderContainer(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
        ],
      );
      addTearDown(container.dispose);

      // Initial state
      final initial = container.read(isFavoriteProvider('p1'));
      expect(initial, isFalse);

      // Add favorite
      await favoriteRepo.toggleFavorite(
        targetId: 'p1',
        targetType: FavoriteTargetType.preset,
      );

      // Wait for stream to update
      await container.read(favoriteIdsStreamProvider.future);

      final updated = container.read(isFavoriteProvider('p1'));
      expect(updated, isTrue);

      final other = container.read(isFavoriteProvider('other'));
      expect(other, isFalse);
    });

    test('homeFavoritesProvider aggregates presets and workouts correctly',
        () async {
      const dummyPreset = PresetRoutine(
        id: 'preset-hiit',
        title: 'HIIT Express',
        description: 'Quick HIIT session',
        category: PresetCategory.hiit,
        difficulty: DifficultyLevel.beginner,
        restBetweenExercisesSeconds: 15,
        exercises: [],
      );

      final dummyWorkout = Workout(
        id: 'workout-custom',
        name: 'My Custom Workout',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
        rounds: 3,
        exercises: const [],
      );

      await favoriteRepo.toggleFavorite(
        targetId: dummyPreset.id,
        targetType: FavoriteTargetType.preset,
      );
      await favoriteRepo.toggleFavorite(
        targetId: dummyWorkout.id,
        targetType: FavoriteTargetType.workout,
      );

      final container = ProviderContainer(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
          presetCatalogProvider.overrideWith((ref) async => [dummyPreset]),
          workoutsListProvider.overrideWith(
            () => _StaticWorkoutsList([dummyWorkout]),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Wait for underlying providers to resolve
      await container.read(allFavoritesStreamProvider.future);
      await container.read(presetCatalogProvider.future);
      await container.read(workoutsListProvider.future);

      // Read home favorites
      final homeFavs = container.read(homeFavoritesProvider).valueOrNull ?? [];

      expect(homeFavs.length, 2);

      final presetItem =
          homeFavs.firstWhere((item) => item.id == dummyPreset.id);
      expect(presetItem, isA<PresetFavoriteItem>());
      expect(presetItem.title, 'HIIT Express');
      expect(presetItem.targetType, FavoriteTargetType.preset);

      final workoutItem =
          homeFavs.firstWhere((item) => item.id == dummyWorkout.id);
      expect(workoutItem, isA<WorkoutFavoriteItem>());
      expect(workoutItem.title, 'My Custom Workout');
      expect(workoutItem.targetType, FavoriteTargetType.workout);
    });
  });
}
