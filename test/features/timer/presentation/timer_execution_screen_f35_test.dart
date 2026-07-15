import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/always_on/application/always_on_providers.dart';
import 'package:interval_timer/features/always_on/domain/no_op_wakelock_driver.dart';
import 'package:interval_timer/features/timer/application/timer_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:interval_timer/features/timer/presentation/timer_execution_screen.dart';

Routine _twoIntervals() {
  return Routine(
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
}

void main() {
  late DateTime fakeNow;
  late TimerController timerController;
  late ProviderContainer container;
  late AppDatabase db;

  setUp(() {
    fakeNow = DateTime.utc(2026);
    timerController = TimerController(now: () => fakeNow);
    // Isolated in-memory DB so F19 always-on → settings prefs share one AppDatabase.
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        wakelockDriverProvider.overrideWithValue(NoOpWakelockDriver()),
        timerControllerProvider.overrideWith(() => timerController),
      ],
    );
  });

  tearDown(() async {
    container.read(timerControllerProvider.notifier).resetToIdle();
    container.dispose();
    await db.close();
  });

  Future<void> pumpExecution(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TimerExecutionScreen()),
      ),
    );
  }

  testWidgets(
    'layout: total remaining + prev/pause/next keys; pause shows Reanudar',
    (tester) async {
      await pumpExecution(tester);

      final controller = container.read(timerControllerProvider.notifier);
      controller.bindRoutine(_twoIntervals());
      controller.start(prepSeconds: 0);
      await tester.pump();

      expect(find.byKey(const Key('total_remaining_display')), findsOneWidget);
      expect(find.byKey(const Key('total_remaining_label')), findsOneWidget);
      expect(find.byKey(const Key('previous_button')), findsOneWidget);
      expect(find.byKey(const Key('pause_resume_button')), findsOneWidget);
      expect(find.byKey(const Key('skip_button')), findsOneWidget);
      expect(find.byKey(const Key('exit_button')), findsOneWidget);
      expect(find.byKey(const Key('countdown_display')), findsOneWidget);
      expect(find.text(UiStrings.pause), findsOneWidget);

      controller.pause();
      await tester.pump();

      expect(find.text(UiStrings.resume), findsOneWidget);
    },
  );

  testWidgets('exit modal: continue does not cancel; leave cancels',
      (tester) async {
    await pumpExecution(tester);

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(_twoIntervals());
    controller.start(prepSeconds: 0);
    // Pause so dialog pumps settle without the 100ms UI ticker.
    controller.pause();
    await tester.pump();

    await tester.tap(find.byKey(const Key('exit_button')));
    await tester.pump(); // open dialog frame

    expect(find.byKey(const Key('exit_confirm_dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('exit_continue_button')));
    await tester.pump(); // close dialog

    expect(find.byKey(const Key('exit_confirm_dialog')), findsNothing);
    expect(
      container.read(timerControllerProvider).status,
      TimerStatus.paused,
    );

    await tester.tap(find.byKey(const Key('exit_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('exit_leave_button')));
    // cancel → idle may show CircularProgressIndicator; avoid pumpAndSettle.
    await tester.pump();

    expect(
      container.read(timerControllerProvider).status,
      TimerStatus.idle,
    );
  });

  testWidgets('next card shows next interval or last state', (tester) async {
    await pumpExecution(tester);

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(_twoIntervals());
    controller.start(prepSeconds: 0);
    controller.pause();
    await tester.pump();

    expect(find.byKey(const Key('next_segment_card')), findsOneWidget);
    expect(find.byKey(const Key('next_segment_name')), findsOneWidget);
    expect(find.text('DESCANSO'), findsOneWidget);

    controller.skipForward();
    // skipForward resumes running — pause again for stable pump.
    controller.pause();
    await tester.pump();

    expect(find.byKey(const Key('last_interval_label')), findsOneWidget);
    expect(find.text(UiStrings.lastInterval), findsOneWidget);
  });
}
