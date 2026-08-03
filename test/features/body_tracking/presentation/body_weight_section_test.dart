import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/body_measurement_repository.dart';
import 'package:interval_timer/features/body_tracking/application/body_tracking_providers.dart';
import 'package:interval_timer/features/calendar_history/presentation/history_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

void main() {
  late AppDatabase db;
  late BodyMeasurementRepository bodyRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    bodyRepo = BodyMeasurementRepository(db);
  });

  tearDown(() async => db.close());

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        bodyMeasurementRepositoryProvider.overrideWithValue(bodyRepo),
      ],
    );
  }

  Future<void> pumpHistory(WidgetTester tester, ProviderContainer container) {
    final view = tester.view;
    view.physicalSize = const Size(800, 2400);
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

  testWidgets('section shows empty CTA inside History scroll (R2, R5, R12)',
      (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('body_weight_section')), findsOneWidget);
    expect(find.byKey(const Key('body_weight_empty')), findsOneWidget);
    expect(find.text(UiStrings.bodyWeightEmptyMessage), findsOneWidget);
    expect(find.byKey(const Key('body_weight_empty_cta')), findsOneWidget);
    // Order: progress → body weight → calendar (no fifth nav destination here).
    expect(find.byKey(const Key('progress_summary_section')), findsOneWidget);
    expect(find.byKey(const Key('history_table_calendar')), findsOneWidget);

    final sectionY = tester.getTopLeft(find.byKey(const Key('body_weight_section'))).dy;
    final calendarY =
        tester.getTopLeft(find.byKey(const Key('history_table_calendar'))).dy;
    final progressY =
        tester.getTopLeft(find.byKey(const Key('progress_summary_section'))).dy;
    expect(progressY, lessThan(sectionY));
    expect(sectionY, lessThan(calendarY));
  });

  testWidgets('with measurement shows chart not empty (R5)', (tester) async {
    await bodyRepo.upsertByLocalDate(
      localDate: '2026-08-01',
      weightKg: 75,
    );
    final container = createContainer();
    addTearDown(container.dispose);

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('body_weight_empty')), findsNothing);
    expect(find.byKey(const Key('body_weight_line_chart')), findsOneWidget);
  });

  testWidgets('form rejects invalid weight (R10)', (tester) async {
    final container = createContainer();
    addTearDown(container.dispose);

    await pumpHistory(tester, container);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('body_weight_empty_cta')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('body_measurement_form')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('body_weight_input')), '10');
    await tester.tap(find.byKey(const Key('body_weight_save_button')));
    await tester.pumpAndSettle();

    expect(find.text(UiStrings.bodyWeightValidationRange), findsOneWidget);
    expect(await bodyRepo.getAll(), isEmpty);
  });
}
