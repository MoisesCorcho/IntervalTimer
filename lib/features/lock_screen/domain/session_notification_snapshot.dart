/// Immutable view of session state for external surfaces (F20).
class SessionNotificationSnapshot {
  const SessionNotificationSnapshot({
    required this.status,
    required this.title,
    required this.remainingMs,
    required this.showPause,
    required this.showResume,
    required this.showSkip,
  });

  /// preparing | running | paused
  final String status;

  /// Interval name or preparation label.
  final String title;

  final int remainingMs;
  final bool showPause;
  final bool showResume;
  final bool showSkip;

  String get remainingFormatted {
    final totalSeconds = (remainingMs / 1000).ceil().clamp(0, 5999);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  SessionNotificationSnapshot copyWith({
    String? status,
    String? title,
    int? remainingMs,
    bool? showPause,
    bool? showResume,
    bool? showSkip,
  }) {
    return SessionNotificationSnapshot(
      status: status ?? this.status,
      title: title ?? this.title,
      remainingMs: remainingMs ?? this.remainingMs,
      showPause: showPause ?? this.showPause,
      showResume: showResume ?? this.showResume,
      showSkip: showSkip ?? this.showSkip,
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'title': title,
        'remainingMs': remainingMs,
        'remainingFormatted': remainingFormatted,
        'showPause': showPause,
        'showResume': showResume,
        'showSkip': showSkip,
      };

  static SessionNotificationSnapshot fromMap(Map<dynamic, dynamic> map) {
    return SessionNotificationSnapshot(
      status: map['status'] as String? ?? 'running',
      title: map['title'] as String? ?? '',
      remainingMs: (map['remainingMs'] as num?)?.toInt() ?? 0,
      showPause: _asBool(map['showPause'], fallback: true),
      showResume: _asBool(map['showResume'], fallback: false),
      showSkip: _asBool(map['showSkip'], fallback: true),
    );
  }

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    return fallback;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SessionNotificationSnapshot &&
            other.status == status &&
            other.title == title &&
            other.remainingMs == remainingMs &&
            other.showPause == showPause &&
            other.showResume == showResume &&
            other.showSkip == showSkip);
  }

  @override
  int get hashCode => Object.hash(
        status,
        title,
        remainingMs,
        showPause,
        showResume,
        showSkip,
      );
}
