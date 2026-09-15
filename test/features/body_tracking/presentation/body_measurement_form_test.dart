import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/body_measurement_repository.dart';
import 'package:interval_timer/features/body_tracking/application/body_tracking_providers.dart';
import 'package:interval_timer/features/body_tracking/presentation/body_measurement_form.dart';
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

  Future<void> pumpFormSheet(
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
            body: BodyMeasurementFormSheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Free user sees ProBadge on body measures tile and tapping it opens PaywallModalScreen',
      (tester) async {
    final container = createContainer(isPro: false);
    addTearDown(container.dispose);

    await pumpFormSheet(tester, container);

    final measuresTile = find.byKey(const Key('body_weight_measures_tile'));
    expect(measuresTile, findsOneWidget);

    // ProBadge is visible in the tile title
    expect(
      find.descendant(of: measuresTile, matching: find.byType(ProBadge)),
      findsOneWidget,
    );

    // Tapping the tile opens PaywallModalScreen
    await tester.tap(measuresTile);
    await tester.pumpAndSettle();

    expect(find.byType(PaywallModalScreen), findsOneWidget);
    // Form fields for waist/arm/leg were NOT expanded into active view
    expect(find.byKey(const Key('body_weight_waist_input')), findsNothing);
  });

  testWidgets('Pro user expands body measures tile without PaywallModalScreen',
      (tester) async {
    final container = createContainer(isPro: true);
    addTearDown(container.dispose);

    await pumpFormSheet(tester, container);

    final measuresTile = find.byKey(const Key('body_weight_measures_tile'));
    expect(measuresTile, findsOneWidget);

    // Tapping expands the inputs for Pro user
    await tester.tap(measuresTile);
    await tester.pumpAndSettle();

    expect(find.byType(PaywallModalScreen), findsNothing);
    expect(find.byKey(const Key('body_weight_waist_input')), findsOneWidget);
  });
}
