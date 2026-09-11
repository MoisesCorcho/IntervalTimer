import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/app/app.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/always_on/application/always_on_providers.dart';
import 'package:interval_timer/features/always_on/domain/no_op_wakelock_driver.dart';
import 'package:interval_timer/features/lock_screen/application/lock_screen_providers.dart';
import 'package:interval_timer/features/lock_screen/domain/no_op_session_surface_driver.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/vibration/application/vibration_providers.dart';
import 'package:interval_timer/features/vibration/domain/no_op_vibration_driver.dart';
import 'package:interval_timer/features/voice/application/voice_providers.dart';
import 'package:interval_timer/features/voice/domain/tts_engine.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

class _FakeTtsEngine implements TtsEngine {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}

void main() {
  group('App themeMode', () {
    late AppDatabase db;
    late PreferencesRepository prefs;
    late SettingsRepository settingsRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      prefs = PreferencesRepository(db);
      settingsRepo = SettingsRepository(prefs);
      await prefs.setHasSeenOnboarding(true);
    });

    tearDown(() async {
      await db.close();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          sessionSurfaceDriverProvider
              .overrideWithValue(NoOpSessionSurfaceDriver()),
          wakelockDriverProvider.overrideWithValue(NoOpWakelockDriver()),
          vibrationDriverProvider.overrideWithValue(NoOpVibrationDriver()),
          ttsEngineProvider.overrideWithValue(_FakeTtsEngine()),
        ],
      );
    }

    Future<void> pumpApp(WidgetTester tester, ProviderContainer container) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      // Settings AsyncNotifier + first frame.
      await tester.pumpAndSettle();
    }

    MaterialApp getMaterialApp(WidgetTester tester) {
      return tester.widget<MaterialApp>(find.byType(MaterialApp));
    }

    testWidgets('applies darkTheme when themeMode is dark (R2)', (tester) async {
      await settingsRepo.setThemeMode(AppThemeMode.dark);
      final container = createContainer();
      addTearDown(container.dispose);

      await pumpApp(tester, container);

      final app = getMaterialApp(tester);
      expect(app.themeMode, ThemeMode.dark);
      expect(app.darkTheme, isNotNull);
      expect(app.darkTheme!.brightness, Brightness.dark);
      expect(app.theme, isNotNull);
      expect(app.theme!.brightness, Brightness.light);

      // Resolved theme on a descendant is dark.
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsWidgets);
      final brightness = Theme.of(tester.element(scaffoldFinder.first)).brightness;
      expect(brightness, Brightness.dark);
    });

    testWidgets('applies light theme when themeMode is light', (tester) async {
      await settingsRepo.setThemeMode(AppThemeMode.light);
      final container = createContainer();
      addTearDown(container.dispose);

      await pumpApp(tester, container);

      final app = getMaterialApp(tester);
      expect(app.themeMode, ThemeMode.light);
      expect(app.theme, isNotNull);
      expect(app.theme!.brightness, Brightness.light);

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsWidgets);
      final brightness = Theme.of(tester.element(scaffoldFinder.first)).brightness;
      expect(brightness, Brightness.light);
    });

    testWidgets('defaults to system themeMode when preference absent (R4)',
        (tester) async {
      final container = createContainer();
      addTearDown(container.dispose);

      await pumpApp(tester, container);

      final app = getMaterialApp(tester);
      expect(app.themeMode, ThemeMode.system);
      expect(app.darkTheme, isNotNull);
      expect(app.theme, isNotNull);
    });

    testWidgets('applies custom themeColor to MaterialApp theme and darkTheme',
        (tester) async {
      const customPrimary = 0xFF00BCD4; // Cyan
      await settingsRepo.setThemeColorArgb(customPrimary);
      final container = createContainer();
      addTearDown(container.dispose);

      await pumpApp(tester, container);

      final app = getMaterialApp(tester);
      expect(app.theme!.colorScheme.primary, ColorScheme.fromSeed(seedColor: const Color(customPrimary), brightness: Brightness.light).primary);
      expect(app.darkTheme!.colorScheme.primary, ColorScheme.fromSeed(seedColor: const Color(customPrimary), brightness: Brightness.dark).primary);
    });
  });
}
