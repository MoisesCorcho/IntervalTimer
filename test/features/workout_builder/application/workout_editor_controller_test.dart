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

  test('updateRounds clamps, persists, and stays AsyncData', () async {
    final workout = await repo.createWorkout('Rounds test');
    final provider = workoutEditorControllerProvider(workout.id);
    final editor = container.read(provider.notifier);
    await container.read(provider.future);

    final states = <AsyncValue<dynamic>>[];
    final sub = container.listen(
      provider,
      (prev, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final ok = await editor.updateRounds(4);
    expect(ok, isTrue);

    final after = container.read(provider);
    expect(after, isA<AsyncData<dynamic>>());
    expect(after.hasValue, isTrue);
    expect(after.requireValue.rounds, 4);
    expect((await repo.getWorkout(workout.id))!.rounds, 4);

    // Mutations must not drop value (no full-screen loading flicker).
    expect(
      states.every((s) => s.hasValue),
      isTrue,
      reason: 'persist must not emit loading-without-value',
    );
  });

  test('updateRounds clamps out-of-range values to 1–99', () async {
    final workout = await repo.createWorkout('Clamp rounds');
    final provider = workoutEditorControllerProvider(workout.id);
    final editor = container.read(provider.notifier);
    await container.read(provider.future);

    expect(await editor.updateRounds(0), isTrue);
    expect(container.read(provider).requireValue.rounds, 1);

    expect(await editor.updateRounds(150), isTrue);
    expect(container.read(provider).requireValue.rounds, 99);
    expect(container.read(provider), isA<AsyncData<dynamic>>());
  });

  test('reorderExercises ends in AsyncData with new order', () async {
    final workout = await repo.createWorkout('Reorder');
    await repo.addExercise(
      workoutId: workout.id,
      name: 'First',
      sets: 1,
      workSeconds: 10,
      restSeconds: 0,
      restAfterExerciseSeconds: 0,
    );
    await repo.addExercise(
      workoutId: workout.id,
      name: 'Second',
      sets: 1,
      workSeconds: 10,
      restSeconds: 0,
      restAfterExerciseSeconds: 0,
    );

    final provider = workoutEditorControllerProvider(workout.id);
    final editor = container.read(provider.notifier);
    await container.read(provider.future);

    final initial = container.read(provider).requireValue;
    final ids = initial.exercises.map((e) => e.id).toList();
    expect(ids, hasLength(2));

    final reordered = [ids[1], ids[0]];
    final states = <AsyncValue<dynamic>>[];
    final sub = container.listen(
      provider,
      (prev, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final ok = await editor.reorderExercises(reordered);
    expect(ok, isTrue);

    final after = container.read(provider);
    expect(after, isA<AsyncData<dynamic>>());
    expect(after.requireValue.exercises.map((e) => e.id).toList(), reordered);
    expect(states.every((s) => s.hasValue), isTrue);
  });
}