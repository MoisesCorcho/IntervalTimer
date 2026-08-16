import 'package:audioplayers/audioplayers.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_player.dart';

/// [SfxPlayer] backed by `audioplayers` with a small pool for overlap.
class AudioPlayersSfxPlayer implements SfxPlayer {
  AudioPlayersSfxPlayer({this.poolSize = 3});

  final int poolSize;
  final List<AudioPlayer> _pool = <AudioPlayer>[];
  int _next = 0;

  @override
  Future<void> playAsset(String assetSourcePath) async {
    try {
      final player = await _acquire();
      // Only stop this pool slot so concurrent SFX on other slots keep playing.
      await player.stop();
      await player.play(AssetSource(assetSourcePath));
    } catch (_) {
      // R12: silent failure.
    }
  }

  Future<AudioPlayer> _acquire() async {
    if (_pool.length < poolSize) {
      final player = AudioPlayer();
      try {
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setAudioContext(
          AudioContext(
            android: const AudioContextAndroid(
              isSpeakerphoneOn: false,
              stayAwake: false,
              contentType: AndroidContentType.sonification,
              usageType: AndroidUsageType.assistanceSonification,
              audioFocus: AndroidAudioFocus.none,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.ambient,
              options: const {
                AVAudioSessionOptions.mixWithOthers,
              },
            ),
          ),
        );
      } catch (_) {
        // Fallback: default media player mode.
      }
      _pool.add(player);
      return player;
    }
    final player = _pool[_next % _pool.length];
    _next++;
    return player;
  }

  @override
  Future<void> dispose() async {
    for (final player in _pool) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _pool.clear();
  }
}
