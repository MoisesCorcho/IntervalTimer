import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:interval_timer/data/repositories/favorite_repository.dart';
import 'package:interval_timer/data/repositories/workout_repository.dart';

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

  group('FavoriteRepository', () {
    test('toggleFavorite switches favorite on and off for preset and workout',
        () async {
      expect(
        await favoriteRepo.isFavorite('preset-1', FavoriteTargetType.preset),
        isFalse,
      );

      final added = await favoriteRepo.toggleFavorite(
        targetId: 'preset-1',
        targetType: FavoriteTargetType.preset,
      );
      expect(added, isTrue);

      expect(
        await favoriteRepo.isFavorite('preset-1', FavoriteTargetType.preset),
        isTrue,
      );

      final removed = await favoriteRepo.toggleFavorite(
        targetId: 'preset-1',
        targetType: FavoriteTargetType.preset,
      );
      expect(removed, isFalse);

      expect(
        await favoriteRepo.isFavorite('preset-1', FavoriteTargetType.preset),
        isFalse,
      );
    });

    test('getAllFavorites returns all persisted favorites', () async {
      await favoriteRepo.toggleFavorite(
        targetId: 'p1',
        targetType: FavoriteTargetType.preset,
      );
      await favoriteRepo.toggleFavorite(
        targetId: 'w1',
        targetType: FavoriteTargetType.workout,
      );

      final all = await favoriteRepo.getAllFavorites();
      expect(all.map((f) => f.targetId), containsAll({'p1', 'w1'}));
      expect(all.length, 2);
    });

    test('watchFavoriteTargetIds and watchAllFavorites emit updates reactively',
        () async {
      final stream = favoriteRepo.watchFavoriteTargetIds();
      final expectation = expectLater(
        stream,
        emitsThrough(containsAll({'preset-1', 'workout-1'})),
      );

      await favoriteRepo.toggleFavorite(
        targetId: 'preset-1',
        targetType: FavoriteTargetType.preset,
      );
      await favoriteRepo.toggleFavorite(
        targetId: 'workout-1',
        targetType: FavoriteTargetType.workout,
      );

      await expectation;
    });

    test('deleteByTargetId removes favorite record', () async {
      await favoriteRepo.toggleFavorite(
        targetId: 'target-to-delete',
        targetType: FavoriteTargetType.preset,
      );
      expect(
        await favoriteRepo.isFavorite(
          'target-to-delete',
          FavoriteTargetType.preset,
        ),
        isTrue,
      );

      await favoriteRepo.deleteByTargetId('target-to-delete');

      expect(
        await favoriteRepo.isFavorite(
          'target-to-delete',
          FavoriteTargetType.preset,
        ),
        isFalse,
      );
    });

    test('WorkoutRepository.deleteWorkout cascades deletion to favorite_routines',
        () async {
      final workout = await workoutRepo.createWorkout('Rutina Test');
      await favoriteRepo.toggleFavorite(
        targetId: workout.id,
        targetType: FavoriteTargetType.workout,
      );

      expect(
        await favoriteRepo.isFavorite(workout.id, FavoriteTargetType.workout),
        isTrue,
      );

      // Delete the workout
      await workoutRepo.deleteWorkout(workout.id);

      // Favorite must also be deleted
      expect(
        await favoriteRepo.isFavorite(workout.id, FavoriteTargetType.workout),
        isFalse,
      );
      final all = await favoriteRepo.getAllFavorites();
      expect(all.where((f) => f.targetId == workout.id), isEmpty);
    });
  });
}
