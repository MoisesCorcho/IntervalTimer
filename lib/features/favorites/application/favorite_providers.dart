import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/data/repositories/favorite_repository.dart';
import 'package:interval_timer/features/preset_routines/application/preset_providers.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return DriftFavoriteRepository(ref.watch(databaseProvider));
});

final favoriteIdsStreamProvider = StreamProvider<Set<String>>((ref) {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.watchFavoriteTargetIds();
});

final isFavoriteProvider = Provider.family<bool, String>((ref, id) {
  final idsAsync = ref.watch(favoriteIdsStreamProvider);
  return idsAsync.valueOrNull?.contains(id) ?? false;
});

final allFavoritesStreamProvider = StreamProvider<List<FavoriteRoutine>>((ref) {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.watchAllFavorites();
});

sealed class FavoriteDisplayItem {
  final String id;
  final String title;
  final String subtitle;
  final FavoriteTargetType targetType;
  final DateTime favoritedAt;

  const FavoriteDisplayItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.targetType,
    required this.favoritedAt,
  });
}

class PresetFavoriteItem extends FavoriteDisplayItem {
  final PresetRoutine preset;
  PresetFavoriteItem({required this.preset, required super.favoritedAt})
      : super(
          id: preset.id,
          title: preset.title,
          subtitle: preset.category.label,
          targetType: FavoriteTargetType.preset,
        );
}

class WorkoutFavoriteItem extends FavoriteDisplayItem {
  final Workout workout;
  WorkoutFavoriteItem({required this.workout, required super.favoritedAt})
      : super(
          id: workout.id,
          title: workout.name,
          subtitle:
              '${workout.exercises.length} ejercicios · ${workout.rounds} rondas',
          targetType: FavoriteTargetType.workout,
        );
}

final homeFavoritesProvider =
    Provider<AsyncValue<List<FavoriteDisplayItem>>>((ref) {
  final favoritesAsync = ref.watch(allFavoritesStreamProvider);
  final presetsAsync = ref.watch(presetCatalogProvider);
  final workoutsAsync = ref.watch(workoutsListProvider);

  if (favoritesAsync.isLoading ||
      presetsAsync.isLoading ||
      workoutsAsync.isLoading) {
    return const AsyncLoading();
  }

  if (favoritesAsync.hasError) {
    return AsyncError(favoritesAsync.error!, favoritesAsync.stackTrace!);
  }

  final favorites = favoritesAsync.value ?? [];
  final presets = presetsAsync.value ?? [];
  final workouts = workoutsAsync.value ?? [];

  final presetMap = {for (final p in presets) p.id: p};
  final workoutMap = {for (final w in workouts) w.id: w};

  final items = <FavoriteDisplayItem>[];
  for (final fav in favorites) {
    if (fav.targetType == FavoriteTargetType.preset) {
      final preset = presetMap[fav.targetId];
      if (preset != null) {
        items.add(
            PresetFavoriteItem(preset: preset, favoritedAt: fav.createdAt));
      }
    } else if (fav.targetType == FavoriteTargetType.workout) {
      final workout = workoutMap[fav.targetId];
      if (workout != null) {
        items.add(
            WorkoutFavoriteItem(workout: workout, favoritedAt: fav.createdAt));
      }
    }
  }

  return AsyncData(items);
});
