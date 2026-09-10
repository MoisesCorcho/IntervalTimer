import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/settings/application/settings_controller.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

void main() {
  group('SettingsController', () {
    late AppDatabase db;
    late PreferencesRepository prefs;
    late SettingsRepository settingsRepo;
    late ProviderContainer container;
    late SettingsController controller;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      prefs = PreferencesRepository(db);
      settingsRepo = SettingsRepository(prefs);
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
        ],
      );
      controller = container.read(settingsControllerProvider.notifier);
      // Wait for initial build.
      await container.read(settingsControllerProvider.future);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('initial state has system themeMode', () async {
      final settings = await container.read(settingsControllerProvider.future);
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('setThemeMode updates state and persists', () async {
      await controller.setThemeMode(AppThemeMode.dark);

      final settings = container.read(settingsControllerProvider).requireValue;
      expect(settings.themeMode, AppThemeMode.dark);
      expect(await prefs.getThemeMode(), 'dark');
      expect(await settingsRepo.getThemeMode(), AppThemeMode.dark);
    });

    test('setThemeMode light updates state', () async {
      await controller.setThemeMode(AppThemeMode.light);

      final settings = container.read(settingsControllerProvider).requireValue;
      expect(settings.themeMode, AppThemeMode.light);
      expect(await prefs.getThemeMode(), 'light');
    });

    test('setPrepSeconds preserves themeMode', () async {
      await controller.setThemeMode(AppThemeMode.dark);
      await controller.setPrepSeconds(30);

      final settings = container.read(settingsControllerProvider).requireValue;
      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.prepSeconds, 30);
    });

    test('setWorkColor updates state and persists', () async {
      const newColor = 0xFFC62828;
      await controller.setWorkColor(newColor);

      final settings = container.read(settingsControllerProvider).requireValue;
      expect(settings.workColorArgb, newColor);
      expect(await settingsRepo.getWorkColorArgb(), newColor);
    });

    test('setRestColor updates state and persists', () async {
      const newColor = 0xFF6A1B9A;
      await controller.setRestColor(newColor);

      final settings = container.read(settingsControllerProvider).requireValue;
      expect(settings.restColorArgb, newColor);
      expect(await settingsRepo.getRestColorArgb(), newColor);
    });
  });
}
