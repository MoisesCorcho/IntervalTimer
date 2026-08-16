import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/music_ducking/application/music_ducking_providers.dart';
import 'package:interval_timer/features/music_ducking/domain/audio_session_manager.dart';
import 'package:interval_timer/features/music_ducking/domain/ducking_tts_engine.dart';
import 'package:interval_timer/features/settings/application/settings_providers.dart';
import 'package:interval_timer/features/settings/data/settings_repository.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/voice/application/voice_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

import '../../../helpers/fake_audio_session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Music ducking providers (F17)', () {
    late AppDatabase db;
    late PreferencesRepository prefs;
    late SettingsRepository settingsRepo;
    late FakeAudioSessionManager fakeSessionManager;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      prefs = PreferencesRepository(db);
      settingsRepo = SettingsRepository(prefs);
      fakeSessionManager = FakeAudioSessionManager();
    });

    tearDown(() async {
      await db.close();
    });

    test('musicDuckingEnabledProvider defaults to true and updates reactively', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          audioSessionManagerProvider.overrideWithValue(fakeSessionManager),
        ],
      );
      addTearDown(container.dispose);

      // Wait for settings to load
      await container.read(settingsControllerProvider.future);

      expect(container.read(musicDuckingEnabledProvider), true);

      await container
          .read(settingsControllerProvider.notifier)
          .setMusicDuckingEnabled(false);

      expect(container.read(musicDuckingEnabledProvider), false);
    });

    test('ttsEngineProvider provides a DuckingTtsEngine wrapping inner engine', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          audioSessionManagerProvider.overrideWithValue(fakeSessionManager),
        ],
      );
      addTearDown(container.dispose);

      final engine = container.read(ttsEngineProvider);
      expect(engine, isA<DuckingTtsEngine>());
    });

    test('audioSessionManagerProvider returns AudioSessionManager', () {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesRepositoryProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final manager = container.read(audioSessionManagerProvider);
      expect(manager, isA<AudioSessionManager>());
    });
  });
}
