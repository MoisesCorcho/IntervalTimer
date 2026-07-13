import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/app/app_shell.dart';
import 'package:interval_timer/app/router.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/features/calendar_history/presentation/history_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

void main() {
  testWidgets('shell has 4 destinations; Historial opens HistoryScreen (R22)',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(UiStrings.navRoutine), findsOneWidget);
    expect(find.text(UiStrings.navWorkouts), findsOneWidget);
    expect(find.text(UiStrings.navHistory), findsOneWidget);
    expect(find.text(UiStrings.navSettings), findsOneWidget);
    expect(find.byKey(const Key('history_nav_destination')), findsOneWidget);

    // Order: index 0 routine, 1 workouts, 2 history, 3 settings
    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.destinations.length, 4);
    expect(
      (nav.destinations[2] as NavigationDestination).label,
      UiStrings.navHistory,
    );
    expect(
      (nav.destinations[3] as NavigationDestination).label,
      UiStrings.navSettings,
    );

    await tester.tap(find.byKey(const Key('history_nav_destination')));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.byKey(const Key('history_screen')), findsOneWidget);
    expect(nav.selectedIndex, anyOf(0, 1, 2, 3)); // re-read below

    final navAfter = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navAfter.selectedIndex, 2);
  });
}
