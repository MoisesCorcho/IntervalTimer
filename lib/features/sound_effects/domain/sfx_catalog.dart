import 'package:interval_timer/features/sound_effects/domain/sfx_entry.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_slot.dart';

/// Static catalog of packaged SFX (defaults + variants).
///
/// Paths are `AssetSource` paths (no `assets/` prefix). Aligned with
/// `assets/sfx/ATTRIBUTION.md`.
class SfxCatalog {
  const SfxCatalog();

  static const defaultWorkStartId = 'sfx_work_start_01';
  static const defaultRestStartId = 'sfx_rest_start_01';
  static const defaultSessionCompleteId = 'sfx_session_complete_01';
  static const defaultPrepTickId = 'sfx_tick_01';
  static const defaultPhaseWarningId = 'sfx_tick_01';

  static const List<SfxEntry> entries = [
    // Defaults
    SfxEntry(
      id: defaultWorkStartId,
      assetSourcePath: 'sfx/default/sfx_work_start_01.mp3',
      suggestedFor: {SfxSlot.workStart},
    ),
    SfxEntry(
      id: defaultRestStartId,
      assetSourcePath: 'sfx/default/sfx_rest_start_01.wav',
      suggestedFor: {SfxSlot.restStart},
    ),
    SfxEntry(
      id: defaultSessionCompleteId,
      assetSourcePath: 'sfx/default/sfx_session_complete_01.wav',
      suggestedFor: {SfxSlot.sessionComplete},
    ),
    SfxEntry(
      id: defaultPrepTickId,
      assetSourcePath: 'sfx/default/sfx_tick_01.wav',
      suggestedFor: {SfxSlot.prepTick, SfxSlot.phaseWarning},
    ),
    // Catalog — work
    SfxEntry(
      id: 'sfx_work_start_02',
      assetSourcePath: 'sfx/catalog/sfx_work_start_02.wav',
      suggestedFor: {SfxSlot.workStart},
    ),
    SfxEntry(
      id: 'sfx_work_start_03',
      assetSourcePath: 'sfx/catalog/sfx_work_start_03.wav',
      suggestedFor: {SfxSlot.workStart},
    ),
    SfxEntry(
      id: 'sfx_work_start_04',
      assetSourcePath: 'sfx/catalog/sfx_work_start_04.wav',
      suggestedFor: {SfxSlot.workStart},
    ),
    SfxEntry(
      id: 'sfx_work_start_05',
      assetSourcePath: 'sfx/catalog/sfx_work_start_05.wav',
      suggestedFor: {SfxSlot.workStart},
    ),
    SfxEntry(
      id: 'sfx_work_start_06',
      assetSourcePath: 'sfx/catalog/sfx_work_start_06.wav',
      suggestedFor: {SfxSlot.workStart},
    ),
    // Catalog — rest
    SfxEntry(
      id: 'sfx_rest_start_02',
      assetSourcePath: 'sfx/catalog/sfx_rest_start_02.wav',
      suggestedFor: {SfxSlot.restStart},
    ),
    SfxEntry(
      id: 'sfx_rest_start_03',
      assetSourcePath: 'sfx/catalog/sfx_rest_start_03.wav',
      suggestedFor: {SfxSlot.restStart},
    ),
    SfxEntry(
      id: 'sfx_rest_start_04',
      assetSourcePath: 'sfx/catalog/sfx_rest_start_04.wav',
      suggestedFor: {SfxSlot.restStart},
    ),
    SfxEntry(
      id: 'sfx_rest_start_05',
      assetSourcePath: 'sfx/catalog/sfx_rest_start_05.wav',
      suggestedFor: {SfxSlot.restStart},
    ),
    SfxEntry(
      id: 'sfx_rest_start_06',
      assetSourcePath: 'sfx/catalog/sfx_rest_start_06.wav',
      suggestedFor: {SfxSlot.restStart},
    ),
    // Catalog — complete
    SfxEntry(
      id: 'sfx_session_complete_02',
      assetSourcePath: 'sfx/catalog/sfx_session_complete_02.wav',
      suggestedFor: {SfxSlot.sessionComplete},
    ),
    SfxEntry(
      id: 'sfx_session_complete_03',
      assetSourcePath: 'sfx/catalog/sfx_session_complete_03.wav',
      suggestedFor: {SfxSlot.sessionComplete},
    ),
    SfxEntry(
      id: 'sfx_session_complete_04',
      assetSourcePath: 'sfx/catalog/sfx_session_complete_04.mp3',
      suggestedFor: {SfxSlot.sessionComplete},
    ),
    SfxEntry(
      id: 'sfx_session_complete_05',
      assetSourcePath: 'sfx/catalog/sfx_session_complete_05.wav',
      suggestedFor: {SfxSlot.sessionComplete},
    ),
    // Catalog — tick
    SfxEntry(
      id: 'sfx_tick_02',
      assetSourcePath: 'sfx/catalog/sfx_tick_02.wav',
      suggestedFor: {SfxSlot.prepTick, SfxSlot.phaseWarning},
    ),
    SfxEntry(
      id: 'sfx_tick_03',
      assetSourcePath: 'sfx/catalog/sfx_tick_03.wav',
      suggestedFor: {SfxSlot.prepTick, SfxSlot.phaseWarning},
    ),
    SfxEntry(
      id: 'sfx_tick_04',
      assetSourcePath: 'sfx/catalog/sfx_tick_04.wav',
      suggestedFor: {SfxSlot.prepTick, SfxSlot.phaseWarning},
    ),
    SfxEntry(
      id: 'sfx_tick_05',
      assetSourcePath: 'sfx/catalog/sfx_tick_05.wav',
      suggestedFor: {SfxSlot.prepTick, SfxSlot.phaseWarning},
    ),
    SfxEntry(
      id: 'sfx_tick_06',
      assetSourcePath: 'sfx/catalog/sfx_tick_06.wav',
      suggestedFor: {SfxSlot.prepTick, SfxSlot.phaseWarning},
    ),
    SfxEntry(
      id: 'sfx_tick_07',
      assetSourcePath: 'sfx/catalog/sfx_tick_07.wav',
      suggestedFor: {SfxSlot.prepTick, SfxSlot.phaseWarning},
    ),
    // Catalog — click (available for any slot; no factory slot)
    SfxEntry(
      id: 'sfx_click_01',
      assetSourcePath: 'sfx/catalog/sfx_click_01.wav',
    ),
    SfxEntry(
      id: 'sfx_click_02',
      assetSourcePath: 'sfx/catalog/sfx_click_02.wav',
    ),
    SfxEntry(
      id: 'sfx_click_03',
      assetSourcePath: 'sfx/catalog/sfx_click_03.wav',
    ),
    SfxEntry(
      id: 'sfx_click_04',
      assetSourcePath: 'sfx/catalog/sfx_click_04.wav',
    ),
  ];

  /// Full catalog for pickers (never filtered by slot).
  List<SfxEntry> get all => entries;

  SfxEntry? resolve(String id) {
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  String defaultId(SfxSlot slot) {
    return switch (slot) {
      SfxSlot.workStart => defaultWorkStartId,
      SfxSlot.restStart => defaultRestStartId,
      SfxSlot.sessionComplete => defaultSessionCompleteId,
      SfxSlot.prepTick => defaultPrepTickId,
      SfxSlot.phaseWarning => defaultPhaseWarningId,
    };
  }

  SfxEntry defaultEntry(SfxSlot slot) {
    return resolve(defaultId(slot))!;
  }

  /// Resolve preferred id, falling back to factory default for the slot.
  SfxEntry resolveOrDefault(String id, SfxSlot slot) {
    return resolve(id) ?? defaultEntry(slot);
  }
}
