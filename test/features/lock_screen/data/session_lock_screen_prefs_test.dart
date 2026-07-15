import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';

void main() {
  group('Session lock screen preferences (R10, R18)', () {
    late AppDatabase db;
    late SettingsRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = SettingsRepository(PreferencesRepository(db));
    });

    tearDown(() async {
      await db.close();
    });

    test('default is true without persisted value', () async {
      expect(await repo.getSessionLockScreenEnabled(), true);
    });

    test('prefs survive re-read and are independent of F19/F02/F18', () async {
      await repo.setSessionLockScreenEnabled(false);
      await repo.setKeepScreenOnEnabled(true);
      await repo.setVoiceEnabled(true);
      await repo.setVibrationEnabled(true);

      final again = SettingsRepository(PreferencesRepository(db));
      expect(await again.getSessionLockScreenEnabled(), false);
      expect(await again.getKeepScreenOnEnabled(), true);
      expect(await again.getVoiceEnabled(), true);
      expect(await again.getVibrationEnabled(), true);

      await again.setSessionLockScreenEnabled(true);
      expect(await again.getSessionLockScreenEnabled(), true);
      // Independencia: F19/F02/F18 no mutados
      expect(await again.getKeepScreenOnEnabled(), true);
      expect(await again.getVoiceEnabled(), true);
      expect(await again.getVibrationEnabled(), true);
    });

    test('toggling F20 does not mutate keep_screen_on / voice / vibration',
        () async {
      await repo.setKeepScreenOnEnabled(false);
      await repo.setVoiceEnabled(false);
      await repo.setVibrationEnabled(false);

      await repo.setSessionLockScreenEnabled(false);
      await repo.setSessionLockScreenEnabled(true);

      expect(await repo.getKeepScreenOnEnabled(), false);
      expect(await repo.getVoiceEnabled(), false);
      expect(await repo.getVibrationEnabled(), false);
    });
  });
}
