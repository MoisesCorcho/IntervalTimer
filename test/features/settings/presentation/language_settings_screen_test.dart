import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/lock_screen/domain/no_op_session_surface_driver.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_language.dart';
import 'package:interval_timer/features/settings/presentation/settings_screen.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  group('SettingsScreen - Language Selector (F28 R3, R8)', () {
    late AppDatabase db;
    late PreferencesRepository prefs;
    late SettingsRepository settingsRepo;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      prefs = PreferencesRepository(db);
      settingsRepo = SettingsRepository(prefs);

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sessionSurfaceDriverProvider.overrideWithValue(NoOpSessionSurfaceDriver()),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    testWidgets('shows language segmented button and defaults to system',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final segmentedButton = find.byKey(const Key('language_segmented_button'));
      expect(segmentedButton, findsOneWidget);

      final buttonWidget =
          tester.widget<SegmentedButton<AppLanguage>>(segmentedButton);
      expect(buttonWidget.selected, equals({AppLanguage.system}));
      expect(
        buttonWidget.segments.map((s) => s.value).toList(),
        equals([AppLanguage.es, AppLanguage.en, AppLanguage.system]),
      );
    });

    testWidgets('tapping Español persists AppLanguage.es to repository immediately',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Español
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      final buttonWidget = tester.widget<SegmentedButton<AppLanguage>>(
        find.byKey(const Key('language_segmented_button')),
      );
      expect(buttonWidget.selected, equals({AppLanguage.es}));

      final saved = await settingsRepo.getAppLanguage();
      expect(saved, AppLanguage.es);
    });

    testWidgets('tapping English persists AppLanguage.en to repository immediately',
        (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      final buttonWidget = tester.widget<SegmentedButton<AppLanguage>>(
        find.byKey(const Key('language_segmented_button')),
      );
      expect(buttonWidget.selected, equals({AppLanguage.en}));

      final saved = await settingsRepo.getAppLanguage();
      expect(saved, AppLanguage.en);
    });
  });
}
