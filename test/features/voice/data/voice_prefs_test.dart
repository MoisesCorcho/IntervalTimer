import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';

void main() {
  group('Voice preferences (R7, R9)', () {
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
      expect(await repo.getVoiceEnabled(), true);
      expect(await repo.getCountdownSeconds(), 3);
      expect(await repo.getAnnounceIntervalName(), true);
    });

    test('countdown out of range clamps', () async {
      await repo.setCountdownSeconds(-1);
      expect(await repo.getCountdownSeconds(), 0);

      await repo.setCountdownSeconds(99);
      expect(await repo.getCountdownSeconds(), 10);
    });

    test('prefs survive re-read', () async {
      await repo.setVoiceEnabled(false);
      await repo.setCountdownSeconds(7);
      await repo.setAnnounceIntervalName(false);

      final again = SettingsRepository(PreferencesRepository(db));
      expect(await again.getVoiceEnabled(), false);
      expect(await again.getCountdownSeconds(), 7);
      expect(await again.getAnnounceIntervalName(), false);
    });
  });
}
