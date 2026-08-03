import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';
import 'package:interval_timer/features/settings/domain/app_theme_mode.dart';

/// Global app settings (F35+ / F02 / F18 / F19 / F20 / F27 / F36 SFX / F15 body weight).
/// Lightweight value object — not Drift. Pure domain (no Flutter imports).
class AppSettings {
  const AppSettings({
    required this.prepSeconds,
    this.voiceEnabled = true,
    this.countdownSeconds = 3,
    this.announceIntervalName = true,
    this.vibrationEnabled = true,
    this.vibrationOnIntervalStart = true,
    this.vibrationOnCountdown = true,
    this.vibrationCountdownSeconds = 3,
    this.soundEnabled = true,
    this.soundOnWorkStart = true,
    this.soundOnRestStart = true,
    this.soundOnSessionComplete = true,
    this.soundOnPrepTick = true,
    this.soundOnPhaseWarning = true,
    this.soundCountdownSeconds = 3,
    this.soundIdWorkStart = 'sfx_work_start_01',
    this.soundIdRestStart = 'sfx_rest_start_01',
    this.soundIdSessionComplete = 'sfx_session_complete_01',
    this.soundIdPrepTick = 'sfx_tick_01',
    this.soundIdPhaseWarning = 'sfx_tick_01',
    this.keepScreenOnEnabled = true,
    this.sessionLockScreenEnabled = true,
    this.themeMode = AppThemeMode.system,
    this.bodyWeightUnit = BodyWeightUnit.kg,
  });

  /// Seconds of preparation before the first interval (0–60).
  final int prepSeconds;

  /// In-app TTS mute (F02). Does not stop the timer.
  final bool voiceEnabled;

  /// Spoken countdown window in seconds (0–10). 0 disables countdown only.
  final int countdownSeconds;

  /// Whether to speak interval name / announceText on interval start.
  final bool announceIntervalName;

  /// Master mute for haptics (F18). Independent of [voiceEnabled].
  final bool vibrationEnabled;

  /// Pattern A at interval start (F18 R1/R4).
  final bool vibrationOnIntervalStart;

  /// Pattern B countdown ticks (F18 R2/R4).
  final bool vibrationOnCountdown;

  /// Haptic countdown window in seconds (0–10). Own key, not F02 countdown.
  final int vibrationCountdownSeconds;

  /// Master mute for packaged SFX (F36). Independent of voice and vibration.
  final bool soundEnabled;

  final bool soundOnWorkStart;
  final bool soundOnRestStart;
  final bool soundOnSessionComplete;
  final bool soundOnPrepTick;
  final bool soundOnPhaseWarning;

  /// Phase-warning countdown window in seconds (0–10). Own key, not F02/F18.
  final int soundCountdownSeconds;

  final String soundIdWorkStart;
  final String soundIdRestStart;
  final String soundIdSessionComplete;
  final String soundIdPrepTick;
  final String soundIdPhaseWarning;

  /// Screen wakelock during active session execution (F19).
  final bool keepScreenOnEnabled;

  /// Ongoing session notification / Live Activity surface (F20).
  final bool sessionLockScreenEnabled;

  /// Theme preference: light, dark, or follow system (F27).
  final AppThemeMode themeMode;

  /// Weight display/edit unit for body tracking UI (F15).
  final BodyWeightUnit bodyWeightUnit;

  AppSettings copyWith({
    int? prepSeconds,
    bool? voiceEnabled,
    int? countdownSeconds,
    bool? announceIntervalName,
    bool? vibrationEnabled,
    bool? vibrationOnIntervalStart,
    bool? vibrationOnCountdown,
    int? vibrationCountdownSeconds,
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
    bool? keepScreenOnEnabled,
    bool? sessionLockScreenEnabled,
    AppThemeMode? themeMode,
    BodyWeightUnit? bodyWeightUnit,
  }) {
    return AppSettings(
      prepSeconds: prepSeconds ?? this.prepSeconds,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      announceIntervalName:
          announceIntervalName ?? this.announceIntervalName,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      vibrationOnIntervalStart:
          vibrationOnIntervalStart ?? this.vibrationOnIntervalStart,
      vibrationOnCountdown:
          vibrationOnCountdown ?? this.vibrationOnCountdown,
      vibrationCountdownSeconds:
          vibrationCountdownSeconds ?? this.vibrationCountdownSeconds,
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
      keepScreenOnEnabled: keepScreenOnEnabled ?? this.keepScreenOnEnabled,
      sessionLockScreenEnabled:
          sessionLockScreenEnabled ?? this.sessionLockScreenEnabled,
      themeMode: themeMode ?? this.themeMode,
      bodyWeightUnit: bodyWeightUnit ?? this.bodyWeightUnit,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AppSettings &&
            other.prepSeconds == prepSeconds &&
            other.voiceEnabled == voiceEnabled &&
            other.countdownSeconds == countdownSeconds &&
            other.announceIntervalName == announceIntervalName &&
            other.vibrationEnabled == vibrationEnabled &&
            other.vibrationOnIntervalStart == vibrationOnIntervalStart &&
            other.vibrationOnCountdown == vibrationOnCountdown &&
            other.vibrationCountdownSeconds == vibrationCountdownSeconds &&
            other.soundEnabled == soundEnabled &&
            other.soundOnWorkStart == soundOnWorkStart &&
            other.soundOnRestStart == soundOnRestStart &&
            other.soundOnSessionComplete == soundOnSessionComplete &&
            other.soundOnPrepTick == soundOnPrepTick &&
            other.soundOnPhaseWarning == soundOnPhaseWarning &&
            other.soundCountdownSeconds == soundCountdownSeconds &&
            other.soundIdWorkStart == soundIdWorkStart &&
            other.soundIdRestStart == soundIdRestStart &&
            other.soundIdSessionComplete == soundIdSessionComplete &&
            other.soundIdPrepTick == soundIdPrepTick &&
            other.soundIdPhaseWarning == soundIdPhaseWarning &&
            other.keepScreenOnEnabled == keepScreenOnEnabled &&
            other.sessionLockScreenEnabled == sessionLockScreenEnabled &&
            other.themeMode == themeMode &&
            other.bodyWeightUnit == bodyWeightUnit);
  }

  @override
  int get hashCode => Object.hashAll([
        prepSeconds,
        voiceEnabled,
        countdownSeconds,
        announceIntervalName,
        vibrationEnabled,
        vibrationOnIntervalStart,
        vibrationOnCountdown,
        vibrationCountdownSeconds,
        soundEnabled,
        soundOnWorkStart,
        soundOnRestStart,
        soundOnSessionComplete,
        soundOnPrepTick,
        soundOnPhaseWarning,
        soundCountdownSeconds,
        soundIdWorkStart,
        soundIdRestStart,
        soundIdSessionComplete,
        soundIdPrepTick,
        soundIdPhaseWarning,
        keepScreenOnEnabled,
        sessionLockScreenEnabled,
        themeMode,
        bodyWeightUnit,
      ]);
}
