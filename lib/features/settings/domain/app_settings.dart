/// Global app settings (F35+ / F02 voice / F18 vibration / F19 always-on).
/// Lightweight value object — not Drift.
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
    this.keepScreenOnEnabled = true,
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

  /// Screen wakelock during active session execution (F19).
  final bool keepScreenOnEnabled;

  AppSettings copyWith({
    int? prepSeconds,
    bool? voiceEnabled,
    int? countdownSeconds,
    bool? announceIntervalName,
    bool? vibrationEnabled,
    bool? vibrationOnIntervalStart,
    bool? vibrationOnCountdown,
    int? vibrationCountdownSeconds,
    bool? keepScreenOnEnabled,
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
      keepScreenOnEnabled: keepScreenOnEnabled ?? this.keepScreenOnEnabled,
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
            other.keepScreenOnEnabled == keepScreenOnEnabled);
  }

  @override
  int get hashCode => Object.hash(
        prepSeconds,
        voiceEnabled,
        countdownSeconds,
        announceIntervalName,
        vibrationEnabled,
        vibrationOnIntervalStart,
        vibrationOnCountdown,
        vibrationCountdownSeconds,
        keepScreenOnEnabled,
      );
}
