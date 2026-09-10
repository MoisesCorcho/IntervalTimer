import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';

void main() {
  group('SettingsRepository', () {
    late AppDatabase db;
    late SettingsRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = SettingsRepository(PreferencesRepository(db));
    });

    tearDown(() async {
      await db.close();
    });

    test('default is 10 when preference absent', () async {
      expect(await repo.getPrepSeconds(), 10);
    });

    test('set 0 and 60 ok', () async {
      await repo.setPrepSeconds(0);
      expect(await repo.getPrepSeconds(), 0);

      await repo.setPrepSeconds(60);
      expect(await repo.getPrepSeconds(), 60);
    });

    test('out of range clamps', () async {
      await repo.setPrepSeconds(-5);
      expect(await repo.getPrepSeconds(), 0);

      await repo.setPrepSeconds(100);
      expect(await repo.getPrepSeconds(), 60);
    });

    test('value survives re-read (mock prefs / same db)', () async {
      await repo.setPrepSeconds(25);
      final again = SettingsRepository(PreferencesRepository(db));
      expect(await again.getPrepSeconds(), 25);
    });

    test('default themeMode is system when preference absent', () async {
      expect(await repo.getThemeMode(), AppThemeMode.system);
    });

    test('set and get themeMode light', () async {
      await repo.setThemeMode(AppThemeMode.light);
      expect(await repo.getThemeMode(), AppThemeMode.light);
    });

    test('set and get themeMode dark', () async {
      await repo.setThemeMode(AppThemeMode.dark);
      expect(await repo.getThemeMode(), AppThemeMode.dark);
    });

    test('themeMode survives re-read', () async {
      await repo.setThemeMode(AppThemeMode.dark);
      final again = SettingsRepository(PreferencesRepository(db));
      expect(await again.getThemeMode(), AppThemeMode.dark);
    });

    test('preferences layer stores theme_mode as string', () async {
      final prefs = PreferencesRepository(db);
      await repo.setThemeMode(AppThemeMode.dark);
      expect(await prefs.getThemeMode(), 'dark');
      expect(await prefs.getString(PreferencesRepository.themeModeKey), 'dark');
    });

    test('default work and rest colors match AppTheme defaults when absent', () async {
      expect(await repo.getWorkColorArgb(), AppTheme.workColor.toARGB32());
      expect(await repo.getRestColorArgb(), AppTheme.restColor.toARGB32());
    });

    test('set and get work and rest colors persists and survives re-read', () async {
      const newWork = 0xFFC62828;
      const newRest = 0xFF6A1B9A;
      await repo.setWorkColorArgb(newWork);
      await repo.setRestColorArgb(newRest);

      expect(await repo.getWorkColorArgb(), newWork);
      expect(await repo.getRestColorArgb(), newRest);

      final again = SettingsRepository(PreferencesRepository(db));
      expect(await again.getWorkColorArgb(), newWork);
      expect(await again.getRestColorArgb(), newRest);
    });

    test('default theme color matches AppTheme.primaryColorArgb when absent', () async {
      expect(await repo.getThemeColorArgb(), AppTheme.primaryColorArgb);
    });

    test('set and get theme color persists and survives re-read', () async {
      const newThemeColor = 0xFFFF9800; // Orange
      await repo.setThemeColorArgb(newThemeColor);

      expect(await repo.getThemeColorArgb(), newThemeColor);

      final again = SettingsRepository(PreferencesRepository(db));
      expect(await again.getThemeColorArgb(), newThemeColor);
    });
  });
}
