/// Global app settings (F35+). Lightweight value object — not Drift.
class AppSettings {
  const AppSettings({required this.prepSeconds});

  /// Seconds of preparation before the first interval (0–60).
  final int prepSeconds;

  AppSettings copyWith({int? prepSeconds}) {
    return AppSettings(prepSeconds: prepSeconds ?? this.prepSeconds);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AppSettings && other.prepSeconds == prepSeconds);
  }

  @override
  int get hashCode => prepSeconds.hashCode;
}
