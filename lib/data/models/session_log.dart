import 'package:interval_timer/data/models/session_log_status.dart';

class SessionLog {
  const SessionLog({
    required this.id,
    required this.sourceId,
    required this.displayName,
    required this.endedAt,
    required this.localDate,
    required this.status,
    required this.totalDurationSeconds,
    required this.itemCount,
    this.note,
  });

  final String id;
  final String sourceId;
  final String displayName;
  final DateTime endedAt;
  final String localDate; // yyyy-MM-dd local
  final SessionLogStatus status;
  final int totalDurationSeconds;
  final int itemCount;
  final String? note;

  SessionLog copyWith({
    String? id,
    String? sourceId,
    String? displayName,
    DateTime? endedAt,
    String? localDate,
    SessionLogStatus? status,
    int? totalDurationSeconds,
    int? itemCount,
    String? note,
    bool clearNote = false,
  }) {
    return SessionLog(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      displayName: displayName ?? this.displayName,
      endedAt: endedAt ?? this.endedAt,
      localDate: localDate ?? this.localDate,
      status: status ?? this.status,
      totalDurationSeconds:
          totalDurationSeconds ?? this.totalDurationSeconds,
      itemCount: itemCount ?? this.itemCount,
      note: clearNote ? null : (note ?? this.note),
    );
  }
}
