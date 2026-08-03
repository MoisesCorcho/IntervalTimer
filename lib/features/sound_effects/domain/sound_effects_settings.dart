import 'package:interval_timer/features/sound_effects/domain/sfx_catalog.dart';
import 'package:interval_timer/features/sound_effects/domain/sfx_slot.dart';

/// Snapshot of F36 SFX preferences used by [SoundEffectsController].
class SoundEffectsSettings {
  const SoundEffectsSettings({
    this.soundEnabled = true,
    this.soundOnWorkStart = true,
    this.soundOnRestStart = true,
    this.soundOnSessionComplete = true,
    this.soundOnPrepTick = true,
    this.soundOnPhaseWarning = true,
    this.soundCountdownSeconds = 3,
    this.soundIdWorkStart = SfxCatalog.defaultWorkStartId,
    this.soundIdRestStart = SfxCatalog.defaultRestStartId,
    this.soundIdSessionComplete = SfxCatalog.defaultSessionCompleteId,
    this.soundIdPrepTick = SfxCatalog.defaultPrepTickId,
    this.soundIdPhaseWarning = SfxCatalog.defaultPhaseWarningId,
  });

  final bool soundEnabled;
  final bool soundOnWorkStart;
  final bool soundOnRestStart;
  final bool soundOnSessionComplete;
  final bool soundOnPrepTick;
  final bool soundOnPhaseWarning;
  final int soundCountdownSeconds;
  final String soundIdWorkStart;
  final String soundIdRestStart;
  final String soundIdSessionComplete;
  final String soundIdPrepTick;
  final String soundIdPhaseWarning;

  static const defaults = SoundEffectsSettings();

  String soundIdFor(SfxSlot slot) {
    return switch (slot) {
      SfxSlot.workStart => soundIdWorkStart,
      SfxSlot.restStart => soundIdRestStart,
      SfxSlot.sessionComplete => soundIdSessionComplete,
      SfxSlot.prepTick => soundIdPrepTick,
      SfxSlot.phaseWarning => soundIdPhaseWarning,
    };
  }

  SoundEffectsSettings copyWith({
    bool? soundEnabled,
    bool? soundOnWorkStart,
    bool? soundOnRestStart,
    bool? soundOnSessionComplete,
    bool? soundOnPrepTick,
    bool? soundOnPhaseWarning,
    int? soundCountdownSeconds,
    String? soundIdWorkStart,
    String? soundIdRestStart,
    String? soundIdSessionComplete,
    String? soundIdPrepTick,
    String? soundIdPhaseWarning,
  }) {
    return SoundEffectsSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundOnWorkStart: soundOnWorkStart ?? this.soundOnWorkStart,
      soundOnRestStart: soundOnRestStart ?? this.soundOnRestStart,
      soundOnSessionComplete:
          soundOnSessionComplete ?? this.soundOnSessionComplete,
      soundOnPrepTick: soundOnPrepTick ?? this.soundOnPrepTick,
      soundOnPhaseWarning: soundOnPhaseWarning ?? this.soundOnPhaseWarning,
      soundCountdownSeconds:
          soundCountdownSeconds ?? this.soundCountdownSeconds,
      soundIdWorkStart: soundIdWorkStart ?? this.soundIdWorkStart,
      soundIdRestStart: soundIdRestStart ?? this.soundIdRestStart,
      soundIdSessionComplete:
          soundIdSessionComplete ?? this.soundIdSessionComplete,
      soundIdPrepTick: soundIdPrepTick ?? this.soundIdPrepTick,
      soundIdPhaseWarning: soundIdPhaseWarning ?? this.soundIdPhaseWarning,
    );
  }
}
