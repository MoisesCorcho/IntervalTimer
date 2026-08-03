import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/app/app_shell.dart';
import 'package:interval_timer/app/router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/calendar_history/presentation/history_screen.dart';
import 'package:interval_timer/features/stats/application/stats_providers.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

void main() {
  late AppDatabase db;
  late SessionLogRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SessionLogRepository(db);
  });

  tearDown(() async => db.close());

  ProviderContainer createContainer({
    List<Override> extra = const [],
  }) {
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sessionLogRepositoryProvider.overrideWithValue(repo),
        ...extra,
      ],
    );
  }

  Future<void> pumpHistory(WidgetTester tester, ProviderContainer container) {
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

  testWidgets('progress block above calendar; empty zeros (R1, R9, R10)',
      (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('progress_summary_section')), findsOneWidget);
    expect(find.byKey(const Key('history_table_calendar')), findsOneWidget);
    expect(find.byKey(const Key('activity_bar_chart')), findsOneWidget);
    expect(find.text(UiStrings.progressSectionTitle), findsOneWidget);

    // Metric zeros + 2×2 stylized grid
    expect(find.byKey(const Key('stat_metrics_grid')), findsOneWidget);
    expect(find.byKey(const Key('stat_metric_streak')), findsOneWidget);
    expect(find.byKey(const Key('stat_metric_week_minutes')), findsOneWidget);
    expect(find.byKey(const Key('stat_metric_month_sessions')), findsOneWidget);
    expect(find.byKey(const Key('stat_metric_kcal')), findsOneWidget);
    expect(find.text(UiStrings.progressStreakLabel), findsOneWidget);
    expect(find.text(UiStrings.progressWeekMinutesLabel), findsOneWidget);
    expect(find.text(UiStrings.progressMonthSessionsLabel), findsOneWidget);
    expect(find.text(UiStrings.progressKcalLabel), findsOneWidget);
    expect(find.text('0'), findsWidgets);

    // 2×2 layout: streak top-left, week top-right, month bottom-left, kcal bottom-right
    final streakTop =
        tester.getTopLeft(find.byKey(const Key('stat_metric_streak')));
    final weekTop =
        tester.getTopLeft(find.byKey(const Key('stat_metric_week_minutes')));
    final monthTop =
        tester.getTopLeft(find.byKey(const Key('stat_metric_month_sessions')));
    final kcalTop =
        tester.getTopLeft(find.byKey(const Key('stat_metric_kcal')));
    expect(streakTop.dy, closeTo(weekTop.dy, 1));
    expect(monthTop.dy, closeTo(kcalTop.dy, 1));
    expect(streakTop.dy, lessThan(monthTop.dy));
    expect(streakTop.dx, lessThan(weekTop.dx));
    expect(monthTop.dx, lessThan(kcalTop.dx));

    // Order: progress section appears before calendar in tree
    final progressY = tester
        .getTopLeft(find.byKey(const Key('progress_summary_section')))
        .dy;
    final calendarY = tester
        .getTopLeft(find.byKey(const Key('history_table_calendar')))
        .dy;
    expect(progressY, lessThan(calendarY));

    // Weight caption when estimated (R12)
    expect(find.byKey(const Key('progress_weight_caption')), findsOneWidget);
    // F15 also shows estimated weight in body_weight_caption; assert progress text only.
    final progressCaption = tester.widget<Text>(
      find.byKey(const Key('progress_weight_caption')),
    );
    expect(progressCaption.data, contains('70'));

    // Honest kcal method disclosure (always visible)
    expect(find.byKey(const Key('progress_kcal_method_caption')), findsOneWidget);
    expect(find.textContaining('No es un gasto medido'), findsOneWidget);
    expect(find.byKey(const Key('progress_kcal_info')), findsOneWidget);

    await tester.tap(find.byKey(const Key('progress_kcal_info')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('progress_kcal_info_dialog')), findsOneWidget);
    // Title reuses the same wording as the metric card label.
    expect(
      find.descendant(
        of: find.byKey(const Key('progress_kcal_info_dialog')),
        matching: find.text(UiStrings.progressKcalInfoTitle),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Compendium'), findsOneWidget);
    await tester.tap(find.byKey(const Key('progress_kcal_info_close')));
    await tester.pumpAndSettle();
  });

  testWidgets('toggle Semana/Mes updates chart period (R4)', (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    final now = DateTime.now();
    await repo.insert(
      sourceId: 'w1',
      displayName: 'Demo',
      endedAt: DateTime(now.year, now.month, now.day, 10),
      status: SessionLogStatus.completed,
      totalDurationSeconds: 120,
      itemCount: 1,
    );

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    expect(container.read(chartPeriodProvider), ChartPeriod.week);

    await tester.tap(find.text(UiStrings.progressChartMonth));
    await tester.pumpAndSettle();

    expect(container.read(chartPeriodProvider), ChartPeriod.month);
    expect(find.byKey(const Key('activity_bar_chart')), findsOneWidget);
  });

  testWidgets('stats error is non-blocking with retry (R11)', (tester) async {
    final container = createContainer(
      extra: [
        sessionLogsForStatsProvider.overrideWith(
          (ref) => Stream.error(Exception('db down')),
        ),
      ],
    );
    addTearDown(container.dispose);

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('progress_stats_error')), findsOneWidget);
    expect(find.text(UiStrings.progressStatsError), findsOneWidget);
    expect(find.byKey(const Key('progress_stats_retry')), findsOneWidget);
    // Calendar still present
    expect(find.byKey(const Key('history_table_calendar')), findsOneWidget);
  });

  testWidgets('shell still has 4 destinations without Progreso tab (R1)',
      (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.destinations.length, 4);
    expect(find.text(UiStrings.navHistory), findsOneWidget);
    expect(find.text('Progreso'), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);

    await tester.tap(find.byKey(const Key('history_nav_destination')));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.byKey(const Key('progress_summary_section')), findsOneWidget);
  });
}
