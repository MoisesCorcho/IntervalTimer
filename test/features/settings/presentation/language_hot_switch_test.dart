import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/app/app.dart';
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
  group('Language Hot-Switch & Bilingual UI (F28 R1, R3, R8)', () {
    late AppDatabase db;
    late PreferencesRepository prefs;
    late SettingsRepository settingsRepo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      prefs = PreferencesRepository(db);
      settingsRepo = SettingsRepository(prefs);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('switching language to English updates MaterialApp locale reactively',
        (tester) async {
      await prefs.setHasSeenOnboarding(true);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            preferencesRepositoryProvider.overrideWithValue(prefs),
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            sessionSurfaceDriverProvider.overrideWithValue(NoOpSessionSurfaceDriver()),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.byKey(const Key('settings_nav_destination')));
      await tester.pumpAndSettle();

      // Switch language to English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Verify that the MaterialApp locale updated
      final context = tester.element(find.byType(SettingsScreen));
      expect(Localizations.localeOf(context).languageCode, 'en');

      // Switch language to Español
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      expect(Localizations.localeOf(context).languageCode, 'es');
    });
  });
}
