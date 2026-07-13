import 'package:drift/drift.dart';
import 'package:interval_timer/core/utils/local_date_format.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:uuid/uuid.dart';

class SessionLogRepository {
  SessionLogRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const maxNoteLength = 500;

  final AppDatabase _db;
  final Uuid _uuid;

  Future<SessionLog> insert({
    required String sourceId,
    required String displayName,
    required DateTime endedAt,
    required SessionLogStatus status,
    required int totalDurationSeconds,
    required int itemCount,
    String? note,
  }) async {
    final id = _uuid.v4();
    final localDate = LocalDateFormat.fromDateTime(endedAt);
    final log = SessionLog(
      id: id,
      sourceId: sourceId,
      displayName: displayName,
      endedAt: endedAt.toUtc(),
      localDate: localDate,
      status: status,
      totalDurationSeconds: totalDurationSeconds,
      itemCount: itemCount,
      note: note,
    );

    await _db.into(_db.sessionLogs).insert(_toRow(log));
    return log;
  }

  Future<List<SessionLog>> getByLocalDate(String localDate) async {
    final rows = await (_db.select(_db.sessionLogs)
          ..where((t) => t.localDate.equals(localDate))
          ..orderBy([(t) => OrderingTerm.desc(t.endedAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Stream<List<SessionLog>> watchByLocalDate(String localDate) {
    return (_db.select(_db.sessionLogs)
          ..where((t) => t.localDate.equals(localDate))
          ..orderBy([(t) => OrderingTerm.desc(t.endedAt)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  /// Returns `yyyy-MM-dd` strings that have at least one log in [focusedMonth].
  Future<Set<String>> getMarkerDatesForMonth(DateTime focusedMonth) async {
    final start = LocalDateFormat.monthStart(focusedMonth);
    final end = LocalDateFormat.monthEnd(focusedMonth);
    final rows = await (_db.select(_db.sessionLogs)
          ..where((t) => t.localDate.isBetweenValues(start, end)))
        .get();
    return rows.map((r) => r.localDate).toSet();
  }

  Stream<Set<String>> watchMarkerDatesForMonth(DateTime focusedMonth) {
    final start = LocalDateFormat.monthStart(focusedMonth);
    final end = LocalDateFormat.monthEnd(focusedMonth);
    return (_db.select(_db.sessionLogs)
          ..where((t) => t.localDate.isBetweenValues(start, end)))
        .watch()
        .map((rows) => rows.map((r) => r.localDate).toSet());
  }

  /// Updates note. Throws [ArgumentError] if longer than [maxNoteLength].
  Future<void> updateNote(String id, String? note) async {
    if (note != null && note.length > maxNoteLength) {
      throw ArgumentError(
        'Note exceeds $maxNoteLength characters',
        'note',
      );
    }
    final value = (note == null || note.trim().isEmpty) ? null : note;
    await (_db.update(_db.sessionLogs)..where((t) => t.id.equals(id))).write(
      SessionLogsCompanion(note: Value(value)),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.sessionLogs)..where((t) => t.id.equals(id))).go();
  }

  SessionLogRow _toRow(SessionLog log) {
    return SessionLogRow(
      id: log.id,
      sourceId: log.sourceId,
      displayName: log.displayName,
      endedAt: log.endedAt.toUtc().millisecondsSinceEpoch,
      localDate: log.localDate,
      status: log.status.storageValue,
      totalDurationSeconds: log.totalDurationSeconds,
      itemCount: log.itemCount,
      note: log.note,
    );
  }

  SessionLog _fromRow(SessionLogRow row) {
    return SessionLog(
      id: row.id,
      sourceId: row.sourceId,
      displayName: row.displayName,
      endedAt: DateTime.fromMillisecondsSinceEpoch(row.endedAt, isUtc: true),
      localDate: row.localDate,
      status: SessionLogStatus.fromStorage(row.status),
      totalDurationSeconds: row.totalDurationSeconds,
      itemCount: row.itemCount,
      note: row.note,
    );
  }
}
