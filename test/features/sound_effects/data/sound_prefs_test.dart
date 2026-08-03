import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SettingsRepository(PreferencesRepository(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('sound prefs defaults', () async {
    expect(await repo.getSoundEnabled(), isTrue);
    expect(await repo.getSoundOnWorkStart(), isTrue);
    expect(await repo.getSoundCountdownSeconds(), 3);
    expect(await repo.getSoundIdWorkStart(), 'sfx_work_start_01');
    expect(await repo.getSoundIdPhaseWarning(), 'sfx_tick_01');
  });

  test('sound countdown clamps to 0..10', () async {
    await repo.setSoundCountdownSeconds(99);
    expect(await repo.getSoundCountdownSeconds(), 10);
    await repo.setSoundCountdownSeconds(-3);
    expect(await repo.getSoundCountdownSeconds(), 0);
  });

  test('sound prefs independent of voice and vibration', () async {
    await repo.setVoiceEnabled(false);
    await repo.setVibrationEnabled(false);
    await repo.setSoundEnabled(true);

    expect(await repo.getVoiceEnabled(), isFalse);
    expect(await repo.getVibrationEnabled(), isFalse);
    expect(await repo.getSoundEnabled(), isTrue);
  });

  test('sound ids persist', () async {
    await repo.setSoundIdWorkStart('sfx_work_start_03');
    expect(await repo.getSoundIdWorkStart(), 'sfx_work_start_03');
  });
}
