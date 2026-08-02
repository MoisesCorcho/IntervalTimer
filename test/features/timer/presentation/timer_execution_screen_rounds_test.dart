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
import 'package:interval_timer/features/timer/presentation/timer_execution_screen.dart';

void main() {
  late AppDatabase db;
  late TimerController timerController;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    timerController = TimerController(now: () => DateTime.utc(2026));
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        wakelockDriverProvider.overrideWithValue(NoOpWakelockDriver()),
        timerControllerProvider.overrideWith(() => timerController),
      ],
    );
  });

  tearDown(() async {
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
    'shows Ronda X de Y when interval has multi-round metadata',
    (tester) async {
      final routine = Routine(
        id: 'r-rounds',
        name: 'Rounds',
        createdAt: DateTime.utc(2026),
        items: [
          RoutineItem.interval(
            const Interval(
              id: 'i1',
              name: 'Trabajo',
              durationSeconds: 60,
              colorArgb: 0xFF4CAF50,
              roundIndex: 2,
              roundCount: 3,
            ),
          ),
        ],
      );

      await pumpExecution(tester);

      final controller = container.read(timerControllerProvider.notifier);
      controller.bindRoutine(routine);
      controller.start(prepSeconds: 0);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final expected = UiStrings.workoutRoundProgress
          .replaceAll('{current}', '2')
          .replaceAll('{total}', '3');

      expect(find.byKey(const Key('workout_round_progress')), findsOneWidget);
      expect(find.text(expected), findsOneWidget);
      expect(find.text('Ronda 2 de 3'), findsOneWidget);

      controller.pause();
      await tester.pump();
    },
  );

  testWidgets(
    'hides round progress when roundCount is 1 or missing',
    (tester) async {
      final routine = Routine(
        id: 'r-single',
        name: 'Single',
        createdAt: DateTime.utc(2026),
        items: [
          RoutineItem.interval(
            const Interval(
              id: 'i1',
              name: 'Trabajo',
              durationSeconds: 60,
              colorArgb: 0xFF4CAF50,
              roundIndex: 1,
              roundCount: 1,
            ),
          ),
          RoutineItem.interval(
            const Interval(
              id: 'i2',
              name: 'Otro',
              durationSeconds: 30,
              colorArgb: 0xFF4CAF50,
            ),
          ),
        ],
      );

      await pumpExecution(tester);

      final controller = container.read(timerControllerProvider.notifier);
      controller.bindRoutine(routine);
      controller.start(prepSeconds: 0);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('workout_round_progress')), findsNothing);
      expect(find.textContaining('Ronda'), findsNothing);

      controller.skip();
      await tester.pump();
      expect(find.byKey(const Key('workout_round_progress')), findsNothing);

      controller.pause();
      await tester.pump();
    },
  );
}
