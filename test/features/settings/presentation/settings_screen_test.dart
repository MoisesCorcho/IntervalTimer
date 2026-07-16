import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/lock_screen/domain/no_op_session_surface_driver.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/presentation/settings_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  group('SettingsScreen', () {
    late AppDatabase db;
    late PreferencesRepository prefs;
    late SettingsRepository settingsRepo;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      prefs = PreferencesRepository(db);
      settingsRepo = SettingsRepository(prefs);
      final sessionSurface = NoOpSessionSurfaceDriver();

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sessionSurfaceDriverProvider.overrideWithValue(sessionSurface),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    testWidgets('shows stepper and changing value updates repo',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('prep_seconds_stepper')), findsOneWidget);
      expect(find.byKey(const Key('prep_number_stepper_value')), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.byKey(const Key('prep_number_stepper_increment')));
      await tester.pumpAndSettle();

      expect(await settingsRepo.getPrepSeconds(), 11);
      expect(find.text('11'), findsOneWidget);
    });

    testWidgets('shows theme segmented button with 3 options',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('theme_segmented_button')), findsOneWidget);
      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Oscuro'), findsOneWidget);
      expect(find.text('Sistema'), findsOneWidget);
    });

    testWidgets('default theme selection is system', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<SegmentedButton<ThemeMode>>(
        find.byKey(const Key('theme_segmented_button')),
      );
      expect(button.selected, {ThemeMode.system});
    });

    testWidgets('selecting dark persists and updates repo', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();

      expect(await settingsRepo.getThemeMode(), ThemeMode.dark);

      final button = tester.widget<SegmentedButton<ThemeMode>>(
        find.byKey(const Key('theme_segmented_button')),
      );
      expect(button.selected, {ThemeMode.dark});
    });
  });
}
