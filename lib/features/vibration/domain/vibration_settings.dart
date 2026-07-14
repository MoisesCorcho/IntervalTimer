/// Snapshot of F18 vibration preferences used by [VibrationFeedbackController].
class VibrationSettings {
  const VibrationSettings({
    this.vibrationEnabled = true,
    this.vibrationOnIntervalStart = true,
    this.vibrationOnCountdown = true,
    this.vibrationCountdownSeconds = 3,
  });

  final bool vibrationEnabled;
  final bool vibrationOnIntervalStart;
  final bool vibrationOnCountdown;
  final int vibrationCountdownSeconds;

  static const defaults = VibrationSettings();

  VibrationSettings copyWith({
    bool? vibrationEnabled,
    bool? vibrationOnIntervalStart,
    bool? vibrationOnCountdown,
    int? vibrationCountdownSeconds,
  }) {
    return VibrationSettings(
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      vibrationOnIntervalStart:
          vibrationOnIntervalStart ?? this.vibrationOnIntervalStart,
      vibrationOnCountdown: vibrationOnCountdown ?? this.vibrationOnCountdown,
      vibrationCountdownSeconds:
          vibrationCountdownSeconds ?? this.vibrationCountdownSeconds,
    );
  }
}
