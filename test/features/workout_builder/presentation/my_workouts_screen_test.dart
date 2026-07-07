import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/models/workout.dart';
import 'package:interval_timer/data/models/workout_exercise.dart';
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

    final container = ProviderContainer(
      overrides: [
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

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UiStrings.train));
    await tester.pumpAndSettle();

    final controller = container.read(timerControllerProvider.notifier);
    final timerState = container.read(timerControllerProvider);
    expect(timerState.status, TimerStatus.running);
    expect(timerState.currentInterval?.name, 'Flexiones');
    expect(find.byType(TimerExecutionScreen), findsOneWidget);
    expect(find.text('Flexiones'), findsOneWidget);

    controller.pause();
    await tester.pump();
  });
}