import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';

void main() {
  group('Keep screen on preferences (R6, R8)', () {
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
      expect(await repo.getKeepScreenOnEnabled(), true);
    });

    test('prefs survive re-read and are independent of voice/vibration',
        () async {
      await repo.setKeepScreenOnEnabled(false);
      await repo.setVoiceEnabled(true);
      await repo.setVibrationEnabled(true);

      final again = SettingsRepository(PreferencesRepository(db));
      expect(await again.getKeepScreenOnEnabled(), false);
      expect(await again.getVoiceEnabled(), true);
      expect(await again.getVibrationEnabled(), true);

      await again.setKeepScreenOnEnabled(true);
      expect(await again.getKeepScreenOnEnabled(), true);
      // Voice/vibration untouched
      expect(await again.getVoiceEnabled(), true);
      expect(await again.getVibrationEnabled(), true);
    });
  });
}
