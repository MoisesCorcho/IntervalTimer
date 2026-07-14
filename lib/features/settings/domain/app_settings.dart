/// Global app settings (F35+ / F02 voice). Lightweight value object — not Drift.
class AppSettings {
  const AppSettings({
    required this.prepSeconds,
    this.voiceEnabled = true,
    this.countdownSeconds = 3,
    this.announceIntervalName = true,
  });

  /// Seconds of preparation before the first interval (0–60).
  final int prepSeconds;

  /// In-app TTS mute (F02). Does not stop the timer.
  final bool voiceEnabled;

  /// Spoken countdown window in seconds (0–10). 0 disables countdown only.
  final int countdownSeconds;

  /// Whether to speak interval name / announceText on interval start.
  final bool announceIntervalName;

  AppSettings copyWith({
    int? prepSeconds,
    bool? voiceEnabled,
    int? countdownSeconds,
    bool? announceIntervalName,
  }) {
    return AppSettings(
      prepSeconds: prepSeconds ?? this.prepSeconds,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      announceIntervalName:
          announceIntervalName ?? this.announceIntervalName,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AppSettings &&
            other.prepSeconds == prepSeconds &&
            other.voiceEnabled == voiceEnabled &&
            other.countdownSeconds == countdownSeconds &&
            other.announceIntervalName == announceIntervalName);
  }

  @override
  int get hashCode => Object.hash(
        prepSeconds,
        voiceEnabled,
        countdownSeconds,
        announceIntervalName,
      );
}
