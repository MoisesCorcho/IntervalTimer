/// Snapshot of F02 voice preferences used by [VoiceAnnouncer].
class VoiceSettings {
  const VoiceSettings({
    this.voiceEnabled = true,
    this.countdownSeconds = 3,
    this.announceIntervalName = true,
  });

  final bool voiceEnabled;
  final int countdownSeconds;
  final bool announceIntervalName;

  static const defaults = VoiceSettings();

  VoiceSettings copyWith({
    bool? voiceEnabled,
    int? countdownSeconds,
    bool? announceIntervalName,
  }) {
    return VoiceSettings(
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      announceIntervalName:
          announceIntervalName ?? this.announceIntervalName,
    );
  }
}
