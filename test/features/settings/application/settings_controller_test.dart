import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/settings/application/settings_controller.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
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
      expect(settings.themeMode, ThemeMode.system);
    });

    test('setThemeMode updates state and persists', () async {
      await controller.setThemeMode(ThemeMode.dark);

      final settings = container.read(settingsControllerProvider).requireValue;
      expect(settings.themeMode, ThemeMode.dark);
      expect(await prefs.getThemeMode(), ThemeMode.dark);
    });

    test('setThemeMode light updates state', () async {
      await controller.setThemeMode(ThemeMode.light);

      final settings = container.read(settingsControllerProvider).requireValue;
      expect(settings.themeMode, ThemeMode.light);
      expect(await prefs.getThemeMode(), ThemeMode.light);
    });

    test('setPrepSeconds preserves themeMode', () async {
      await controller.setThemeMode(ThemeMode.dark);
      await controller.setPrepSeconds(30);

      final settings = container.read(settingsControllerProvider).requireValue;
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.prepSeconds, 30);
    });
  });
}
