import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/timer/presentation/session_completed_screen.dart';

void main() {
  testWidgets('shows confirmation and back button returns to idle', (
    tester,
  ) async {
    final routine = Routine(
      id: 'r1',
      name: 'Test',
      createdAt: DateTime.utc(2026),
      items: [
        RoutineItem.interval(
          Interval(
            id: 'i1',
            name: 'Trabajo',
            durationSeconds: 10,
            colorArgb: 0xFF4CAF50,
          ),
        ),
      ],
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(routine);
    controller.start();
    controller.skip();

    expect(
      container.read(timerControllerProvider).status,
      TimerStatus.completed,
    );

    final router = GoRouter(
      initialLocation: '/completed',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Text('Editor')),
        ),
        GoRoute(
          path: '/completed',
          builder: (context, state) => const SessionCompletedScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.byKey(const Key('session_completed_title')), findsOneWidget);
    expect(find.text(UiStrings.sessionCompleted), findsOneWidget);
    expect(find.byKey(const Key('back_to_routine_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('back_to_routine_button')));
    await tester.pumpAndSettle();

    expect(
      container.read(timerControllerProvider).status,
      TimerStatus.idle,
    );
    expect(find.text('Editor'), findsOneWidget);
  });
}