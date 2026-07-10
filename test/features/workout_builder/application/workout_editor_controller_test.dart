import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/repositories/workout_repository.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository repo;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = WorkoutRepository(db);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        workoutRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('addExercise rejects invalid sets', () async {
    final workout = await repo.createWorkout('Test');
    final provider = workoutEditorControllerProvider(workout.id);
    final editor = container.read(provider.notifier);

    await container.read(provider.future);

    final ok = await editor.addExercise(
      name: 'Push-ups',
      sets: 0,
      workSeconds: 40,
      restSeconds: 20,
      restAfterExerciseSeconds: 0,
    );
    expect(ok, isFalse);
  });

  test('canDeleteWorkout is false while timer running', () async {
    final workout = await repo.createWorkout('Test');
    final timerController = TimerController();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        workoutRepositoryProvider.overrideWithValue(repo),
        timerControllerProvider.overrideWith(() => timerController),
      ],
    );

    final provider = workoutEditorControllerProvider(workout.id);
    final editor = container.read(provider.notifier);
    await container.read(provider.future);

    final timer = container.read(timerControllerProvider.notifier);
    timer.loadFlattenedWorkout(
      workoutId: workout.id,
      workoutName: workout.name,
      flattened: [
        const Interval(
          id: 'i-1',
          name: 'A',
          durationSeconds: 5,
          colorArgb: 0xFF4CAF50,
        ),
      ],
    );
    timer.start();

    expect(editor.canDeleteWorkout, isFalse);
    expect(container.read(timerControllerProvider).status, TimerStatus.running);
  });
}