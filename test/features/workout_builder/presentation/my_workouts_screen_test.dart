import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/data/models/workout_exercise.dart';
import 'package:interval_timer/features/always_on/application/always_on_providers.dart';
import 'package:interval_timer/features/always_on/domain/no_op_wakelock_driver.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/timer/presentation/timer_execution_screen.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workouts_list_controller.dart';
import 'package:interval_timer/features/workout_builder/presentation/my_workouts_screen.dart';

class _StaticWorkoutsList extends WorkoutsListController {
  _StaticWorkoutsList(this.workouts);

  final List<Workout> workouts;

  @override
  Future<List<Workout>> build() async => workouts;
}

class _TestActiveWorkoutId extends ActiveWorkoutIdController {
  @override
  Future<String?> build() async => null;

  @override
  Future<void> setActiveWorkoutId(String? workoutId) async {
    state = AsyncData(workoutId);
  }
}

void main() {
  testWidgets('my workouts shows name and exercise count', (tester) async {
    final workout = Workout(
      id: 'w-1',
      name: 'Full body',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      exercises: const [
        WorkoutExercise(
          id: 'e-1',
          workoutId: 'w-1',
          position: 0,
          name: 'Rows',
          sets: 2,
          workSeconds: 30,
          restSeconds: 10,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutsListProvider.overrideWith(() => _StaticWorkoutsList([workout])),
        ],
        child: const MaterialApp(
          home: MyWorkoutsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Full body'), findsOneWidget);
    expect(find.text('1 ejercicios'), findsOneWidget);
    expect(find.textContaining('rondas'), findsNothing);
  });

  testWidgets('list shows rounds chip only when rounds > 1', (tester) async {
    final single = Workout(
      id: 'w-1',
      name: 'Single pass',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      rounds: 1,
      exercises: const [
        WorkoutExercise(
          id: 'e-1',
          workoutId: 'w-1',
          position: 0,
          name: 'Rows',
          sets: 1,
          workSeconds: 30,
          restSeconds: 0,
        ),
      ],
    );
    final multi = Workout(
      id: 'w-2',
      name: 'Multi round',
      createdAt: DateTime.utc(2026, 1, 2),
      updatedAt: DateTime.utc(2026, 1, 2),
      rounds: 3,
      exercises: const [
        WorkoutExercise(
          id: 'e-2',
          workoutId: 'w-2',
          position: 0,
          name: 'Squats',
          sets: 1,
          workSeconds: 40,
          restSeconds: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutsListProvider.overrideWith(
            () => _StaticWorkoutsList([single, multi]),
          ),
        ],
        child: const MaterialApp(
          home: MyWorkoutsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('workout_rounds_chip_w-1')), findsNothing);
    expect(find.byKey(const Key('workout_rounds_chip_w-2')), findsOneWidget);
    expect(find.text('3 rondas'), findsOneWidget);
  });

  testWidgets('train starts timer and navigates to execute', (tester) async {
    final workout = Workout(
      id: 'w-1',
      name: 'Full body',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      exercises: const [
        WorkoutExercise(
          id: 'e-1',
          workoutId: 'w-1',
          position: 0,
          name: 'Flexiones',
          sets: 2,
          workSeconds: 40,
          restSeconds: 20,
        ),
      ],
    );

    // Isolated in-memory DB when navigating to TimerExecutionScreen (F19 always-on prefs).
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        wakelockDriverProvider.overrideWithValue(NoOpWakelockDriver()),
        workoutsListProvider.overrideWith(() => _StaticWorkoutsList([workout])),
        activeWorkoutIdProvider.overrideWith(_TestActiveWorkoutId.new),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/workouts',
      routes: [
        GoRoute(
          path: '/workouts',
          builder: (context, state) => const MyWorkoutsScreen(),
        ),
        GoRoute(
          path: '/execute',
          builder: (context, state) => const TimerExecutionScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('workout_overflow_w-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workout_sheet_train')));
    await tester.pumpAndSettle();

    final controller = container.read(timerControllerProvider.notifier);
    final timerState = container.read(timerControllerProvider);
    // F35: default prep_seconds is 10 → session starts in preparation.
    expect(timerState.status, TimerStatus.preparing);
    expect(timerState.sessionPrepSeconds, 10);
    expect(find.byType(TimerExecutionScreen), findsOneWidget);
    expect(find.text(UiStrings.preparation), findsOneWidget);

    controller.pause();
    await tester.pump();
  });
}