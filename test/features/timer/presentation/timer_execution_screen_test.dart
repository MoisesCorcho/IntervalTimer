import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/presentation/timer_execution_screen.dart';

void main() {
  testWidgets('execution screen shows time, current and next interval', (
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
            durationSeconds: 60,
            colorArgb: 0xFF4CAF50,
          ),
        ),
        RoutineItem.interval(
          Interval(
            id: 'i2',
            name: 'Descanso',
            durationSeconds: 30,
            colorArgb: 0xFF2196F3,
          ),
        ),
      ],
    );

    final timerController =
        TimerController(now: () => DateTime.utc(2026));
    final container = ProviderContainer(
      overrides: [
        timerControllerProvider.overrideWith(() => timerController),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TimerExecutionScreen()),
      ),
    );

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(routine);
    controller.start(prepSeconds: 0);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('countdown_display')), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
    expect(find.byKey(const Key('current_interval_name')), findsOneWidget);
    expect(find.text('Trabajo'), findsOneWidget);
    expect(find.text(UiStrings.nextInterval), findsWidgets);
    expect(find.text('Descanso'), findsOneWidget);

    controller.pause();
    await tester.pump();
  });
}