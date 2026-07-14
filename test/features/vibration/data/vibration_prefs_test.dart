import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';

void main() {
  group('Vibration preferences (R6, R8)', () {
    late AppDatabase db;
    late SettingsRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = SettingsRepository(PreferencesRepository(db));
    });

    tearDown(() async {
      await db.close();
    });

    test('defaults', () async {
      expect(await repo.getVibrationEnabled(), true);
      expect(await repo.getVibrationOnIntervalStart(), true);
      expect(await repo.getVibrationOnCountdown(), true);
      expect(await repo.getVibrationCountdownSeconds(), 3);
    });

    test('countdown out of range clamps', () async {
      await repo.setVibrationCountdownSeconds(-1);
      expect(await repo.getVibrationCountdownSeconds(), 0);

      await repo.setVibrationCountdownSeconds(99);
      expect(await repo.getVibrationCountdownSeconds(), 10);
    });

    test('prefs survive re-read and are independent of voice', () async {
      await repo.setVibrationEnabled(false);
      await repo.setVibrationOnIntervalStart(false);
      await repo.setVibrationOnCountdown(false);
      await repo.setVibrationCountdownSeconds(7);
      await repo.setVoiceEnabled(true);
      await repo.setCountdownSeconds(5);

      final again = SettingsRepository(PreferencesRepository(db));
      expect(await again.getVibrationEnabled(), false);
      expect(await again.getVibrationOnIntervalStart(), false);
      expect(await again.getVibrationOnCountdown(), false);
      expect(await again.getVibrationCountdownSeconds(), 7);
      // Voice keys untouched / independent
      expect(await again.getVoiceEnabled(), true);
      expect(await again.getCountdownSeconds(), 5);
    });
  });
}
