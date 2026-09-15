import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/body_measurement_repository.dart';
import 'package:interval_timer/features/body_tracking/application/body_tracking_providers.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_weight_history_sheet.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/presentation/screens/paywall_modal_screen.dart';
import 'package:interval_timer/features/pro_tier/presentation/widgets/pro_badge.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

void main() {
  late AppDatabase db;
  late BodyMeasurementRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BodyMeasurementRepository(db);
  });

  tearDown(() async => db.close());

  ProviderContainer createContainer({required bool isPro}) {
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        bodyMeasurementRepositoryProvider.overrideWithValue(repo),
        isProUserProvider.overrideWith((ref) => Stream.value(isPro)),
      ],
    );
  }

  Future<void> seedMeasurements(int count) async {
    for (int i = 1; i <= count; i++) {
      final day = i.toString().padLeft(2, '0');
      await repo.upsertByLocalDate(
        localDate: '2026-08-$day',
        weightKg: 70.0 + i,
      );
    }
  }

  Future<void> pumpHistorySheet(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(800, 2400);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: BodyWeightHistorySheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Free user with 7 measurements sees only 5 items and 1 locked Pro card',
      (tester) async {
    await seedMeasurements(7);
    final container = createContainer(isPro: false);
    addTearDown(container.dispose);

    await pumpHistorySheet(tester, container);

    // Visible: 2026-08-07 down to 2026-08-03 (reversed, newest first)
    expect(find.textContaining('2026-08-07'), findsOneWidget);
    expect(find.textContaining('2026-08-03'), findsOneWidget);
    // Hidden: 2026-08-02 and 2026-08-01
    expect(find.textContaining('2026-08-02'), findsNothing);
    expect(find.textContaining('2026-08-01'), findsNothing);

    // Locked card is present with ProBadge
    final lockedCard = find.byKey(const Key('body_weight_history_pro_locked_card'));
    expect(lockedCard, findsOneWidget);
    expect(
      find.descendant(of: lockedCard, matching: find.byType(ProBadge)),
      findsOneWidget,
    );
  });

  testWidgets('Free user tapping locked Pro card opens PaywallModalScreen',
      (tester) async {
    await seedMeasurements(7);
    final container = createContainer(isPro: false);
    addTearDown(container.dispose);

    await pumpHistorySheet(tester, container);

    final lockedCard = find.byKey(const Key('body_weight_history_pro_locked_card'));
    await tester.tap(lockedCard);
    await tester.pumpAndSettle();

    expect(find.byType(PaywallModalScreen), findsOneWidget);
  });

  testWidgets('Pro user with 7 measurements sees all 7 items and NO locked Pro card',
      (tester) async {
    await seedMeasurements(7);
    final container = createContainer(isPro: true);
    addTearDown(container.dispose);

    await pumpHistorySheet(tester, container);

    expect(find.textContaining('2026-08-07'), findsOneWidget);
    expect(find.textContaining('2026-08-01'), findsOneWidget);
    expect(
      find.byKey(const Key('body_weight_history_pro_locked_card')),
      findsNothing,
    );
  });
}
