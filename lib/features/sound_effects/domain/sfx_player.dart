/// Plays short packaged SFX one-shots (F36).
///
/// Implementations must never throw to callers of the feedback controller;
/// swallow I/O / codec / platform errors (R12).
abstract class SfxPlayer {
  /// [assetSourcePath] is the path for Flutter [AssetSource] (no `assets/` prefix).
  Future<void> playAsset(String assetSourcePath);

  Future<void> dispose();
}
