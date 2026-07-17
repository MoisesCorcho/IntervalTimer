import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
