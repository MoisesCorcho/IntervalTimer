import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/session_summary/application/session_summary_controller.dart';
import 'package:interval_timer/features/session_summary/application/session_summary_providers.dart';
import 'package:interval_timer/features/session_summary/domain/share_image_renderer.dart';
import 'package:interval_timer/features/session_summary/domain/share_sheet_driver.dart';
import 'package:interval_timer/features/session_summary/presentation/session_complete_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/timer/application/timer_state.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  testWidgets('shows confirmation and Listo returns to idle (F16)', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = SessionLogRepository(db);

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

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sessionLogRepositoryProvider.overrideWithValue(repo),
        sessionSummaryControllerProvider.overrideWith(
          () => SessionSummaryController(
            repository: repo,
            shareDriver: FakeShareSheetDriver(),
            imageRenderer: FakeShareImageRenderer(),
            tempFileWriter: (bytes) async => XFile.fromData(
              bytes,
              mimeType: 'image/png',
              name: 't.png',
            ),
            logResolveAttempts: 2,
            logResolveDelay: Duration.zero,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(timerControllerProvider.notifier);
    controller.bindRoutine(routine);
    controller.start(prepSeconds: 0);
    var guard = 0;
    while (container.read(timerControllerProvider).status !=
            TimerStatus.completed &&
        guard < 10) {
      controller.skipForward();
      guard++;
    }

    final router = GoRouter(
      initialLocation: '/completed',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Editor')),
        ),
        GoRoute(
          path: '/completed',
          builder: (context, state) => const SessionCompleteScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const Key('session_completed_title')), findsOneWidget);
    expect(find.text(UiStrings.sessionSummaryGreatJob), findsOneWidget);
    expect(find.byKey(const Key('back_to_routine_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('back_to_routine_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      container.read(timerControllerProvider).status,
      TimerStatus.idle,
    );
    expect(find.text('Editor'), findsOneWidget);
  });
}
