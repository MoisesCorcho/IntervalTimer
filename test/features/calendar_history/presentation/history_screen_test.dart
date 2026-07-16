import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/calendar_history/application/history_controller.dart';
import 'package:interval_timer/features/calendar_history/presentation/history_screen.dart';
import 'package:interval_timer/features/calendar_history/presentation/widgets/session_log_actions_sheet.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

void main() {
  late AppDatabase db;
  late SessionLogRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SessionLogRepository(db);
  });

  tearDown(() async => db.close());

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sessionLogRepositoryProvider.overrideWithValue(repo),
      ],
    );
  }

  Future<void> pumpHistory(WidgetTester tester, ProviderContainer container) {
    // Tall surface so F12 progress + calendar + day list fit without flaky scroll.
    final view = tester.view;
    view.physicalSize = const Size(800, 2000);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
  }

  testWidgets('header and today update selection (R4, R5, R6)', (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('history_month_selector')), findsOneWidget);
    expect(find.byKey(const Key('history_today_button')), findsOneWidget);
    expect(find.byKey(const Key('history_table_calendar')), findsOneWidget);

    container.read(historyControllerProvider.notifier).setFocusedMonth(
          DateTime(2025, 3),
        );
    await tester.pumpAndSettle();
    expect(
      container.read(historyControllerProvider).focusedMonth.month,
      3,
    );
    expect(
      container.read(historyControllerProvider).focusedMonth.year,
      2025,
    );

    await tester.tap(find.byKey(const Key('history_today_button')));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final state = container.read(historyControllerProvider);
    expect(state.selectedDate.day, now.day);
    expect(state.focusedMonth.month, now.month);
  });

  testWidgets('cards show title duration exercises and note placeholder (R10, R11)',
      (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    final now = DateTime.now();
    final log = await repo.insert(
      sourceId: 'w1',
      displayName: 'Entrenamiento demo',
      endedAt: DateTime(now.year, now.month, now.day, 11, 21),
      status: SessionLogStatus.completed,
      totalDurationSeconds: 15,
      itemCount: 1,
    );

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    expect(find.text('Entrenamiento demo'), findsOneWidget);
    expect(find.text('15s'), findsOneWidget);
    expect(find.text('Ejercicios: 1'), findsOneWidget);
    expect(find.text(UiStrings.historyAddNote), findsOneWidget);
    expect(find.byKey(Key('session_log_card_${log.id}')), findsOneWidget);
  });

  testWidgets('overflow sheet has Empezar and Eliminar only (R13)',
      (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    final now = DateTime.now();
    final log = await repo.insert(
      sourceId: 'w1',
      displayName: 'Sesión',
      endedAt: DateTime(now.year, now.month, now.day, 10),
      status: SessionLogStatus.completed,
      totalDurationSeconds: 20,
      itemCount: 2,
    );

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('session_log_overflow_${log.id}')));
    await tester.pumpAndSettle();

    expect(find.byType(SessionLogActionsSheet), findsOneWidget);
    expect(find.byKey(const Key('history_sheet_start')), findsOneWidget);
    expect(find.byKey(const Key('history_sheet_delete')), findsOneWidget);
    expect(find.text(UiStrings.historyStart), findsOneWidget);
    expect(find.text(UiStrings.historyDelete), findsOneWidget);
    expect(find.textContaining('Compartir'), findsNothing);
    expect(find.textContaining('Guardar en'), findsNothing);
  });

  testWidgets('empty day shows empty message (R16)', (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('history_empty_day')), findsOneWidget);
    expect(find.text(UiStrings.historyEmptyDay), findsOneWidget);
  });
}
