import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/music_ducking/data/default_audio_session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DefaultAudioSessionManager (R1, R10, R11)', () {
    test('initial state has 0 active duckings', () {
      final manager = DefaultAudioSessionManager();
      expect(manager.activeDuckingCount, 0);
      expect(manager.isDuckingActive, false);
    });

    test('activate and deactivate manage reference counts', () async {
      final manager = DefaultAudioSessionManager();

      await manager.activateDucking();
      expect(manager.activeDuckingCount, 1);
      expect(manager.isDuckingActive, true);

      await manager.activateDucking();
      expect(manager.activeDuckingCount, 2);
      expect(manager.isDuckingActive, true);

      await manager.deactivateDucking();
      expect(manager.activeDuckingCount, 1);
      expect(manager.isDuckingActive, true);

      await manager.deactivateDucking();
      expect(manager.activeDuckingCount, 0);
      expect(manager.isDuckingActive, false);

      // Deactivating past 0 does not go negative
      await manager.deactivateDucking();
      expect(manager.activeDuckingCount, 0);
      expect(manager.isDuckingActive, false);
    });
  });
}
