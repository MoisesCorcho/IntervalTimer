import 'package:interval_timer/features/sound_effects/domain/sfx_player.dart';

/// No-op player for tests and environments without audio.
class NoOpSfxPlayer implements SfxPlayer {
  final List<String> plays = <String>[];

  @override
  Future<void> playAsset(String assetSourcePath) async {
    plays.add(assetSourcePath);
  }

  @override
  Future<void> dispose() async {}
}
