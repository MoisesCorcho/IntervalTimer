import 'package:interval_timer/features/sound_effects/domain/sfx_slot.dart';

/// One packaged SFX clip in the catalog.
class SfxEntry {
  const SfxEntry({
    required this.id,
    required this.assetSourcePath,
    this.suggestedFor = const {},
  });

  /// Stable id (e.g. `sfx_work_start_01`), stored in prefs.
  final String id;

  /// Path for [AssetSource] — relative to assets root, no `assets/` prefix.
  /// Example: `sfx/default/sfx_tick_01.wav`.
  final String assetSourcePath;

  /// Optional UI metadata (never used to hide entries from the picker).
  final Set<SfxSlot> suggestedFor;
}
