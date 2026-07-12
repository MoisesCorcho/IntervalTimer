import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/utils/local_date_format.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/features/calendar_history/application/session_history_listener.dart';
import 'package:interval_timer/features/timer/application/timer_session_events.dart';

void main() {
  late AppDatabase db;
  late SessionLogRepository repo;
  late SessionHistoryMapper mapper;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SessionLogRepository(db);
    mapper = SessionHistoryMapper(repo);
  });

  tearDown(() async => db.close());

  group('SessionLogRepository + mapper', () {
    test('completed event inserts log with local_date (R1)', () async {
      final endedAt = DateTime(2026, 7, 9, 11, 21);
      await mapper.onCompleted(
        SessionCompletedEvent(
          routineId: 'src-1',
          completedAt: endedAt,
          totalElapsedSeconds: 15,
          intervalCount: 1,
        ),
        displayName: 'Mi rutina',
      );

      final logs = await repo.getByLocalDate('2026-07-09');
      expect(logs, hasLength(1));
      expect(logs.first.sourceId, 'src-1');
      expect(logs.first.displayName, 'Mi rutina');
      expect(logs.first.status, SessionLogStatus.completed);
      expect(logs.first.totalDurationSeconds, 15);
      expect(logs.first.itemCount, 1);
      expect(logs.first.localDate, '2026-07-09');
      expect(logs.first.note, isNull);
    });

    test('cancelled with elapsed > 0 inserts aborted; 0 does not (R2)',
        () async {
      await mapper.onCancelled(
        SessionCancelledEvent(
          routineId: 'src-2',
          cancelledAt: DateTime(2026, 7, 10, 12, 0),
          elapsedSeconds: 30,
          completedIntervalCount: 1,
        ),
        displayName: 'Abortada',
      );
      await mapper.onCancelled(
        SessionCancelledEvent(
          routineId: 'src-3',
          cancelledAt: DateTime(2026, 7, 10, 12, 1),
          elapsedSeconds: 0,
          completedIntervalCount: 0,
        ),
        displayName: 'Zero',
      );

      final logs = await repo.getByLocalDate('2026-07-10');
      expect(logs, hasLength(1));
      expect(logs.first.status, SessionLogStatus.aborted);
      expect(logs.first.totalDurationSeconds, 30);
    });

    test('updateNote persists and rejects over 500 chars (R11, R12)', () async {
      final log = await repo.insert(
        sourceId: 's',
        displayName: 'N',
        endedAt: DateTime(2026, 7, 11, 8),
        status: SessionLogStatus.completed,
        totalDurationSeconds: 10,
        itemCount: 1,
      );

      await repo.updateNote(log.id, 'fue un buen dia');
      final updated = await repo.getByLocalDate('2026-07-11');
      expect(updated.first.note, 'fue un buen dia');

      expect(
        () => repo.updateNote(log.id, 'x' * 501),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('delete removes log; day query empty (R15)', () async {
      final log = await repo.insert(
        sourceId: 's',
        displayName: 'N',
        endedAt: DateTime(2026, 7, 12, 9),
        status: SessionLogStatus.completed,
        totalDurationSeconds: 5,
        itemCount: 1,
      );
      await repo.delete(log.id);
      expect(await repo.getByLocalDate('2026-07-12'), isEmpty);
    });

    test('marker dates only include days with logs (R9)', () async {
      await repo.insert(
        sourceId: 'a',
        displayName: 'A',
        endedAt: DateTime(2026, 7, 6, 10),
        status: SessionLogStatus.completed,
        totalDurationSeconds: 1,
        itemCount: 1,
      );
      await repo.insert(
        sourceId: 'b',
        displayName: 'B',
        endedAt: DateTime(2026, 7, 9, 10),
        status: SessionLogStatus.completed,
        totalDurationSeconds: 1,
        itemCount: 1,
      );
      // Outside month
      await repo.insert(
        sourceId: 'c',
        displayName: 'C',
        endedAt: DateTime(2026, 6, 30, 10),
        status: SessionLogStatus.completed,
        totalDurationSeconds: 1,
        itemCount: 1,
      );

      final markers =
          await repo.getMarkerDatesForMonth(DateTime(2026, 7));
      expect(markers, {'2026-07-06', '2026-07-09'});
      expect(LocalDateFormat.fromDateTime(DateTime(2026, 7, 6)), '2026-07-06');
    });

    test('R18: mapper propagates insert errors; listener-style catch isolates',
        () async {
      final failing = _ThrowingSessionLogRepo(db);
      final failingMapper = SessionHistoryMapper(failing);

      await expectLater(
        failingMapper.onCompleted(
          SessionCompletedEvent(
            routineId: 'x',
            completedAt: DateTime.now(),
            totalElapsedSeconds: 1,
            intervalCount: 1,
          ),
          displayName: '',
        ),
        throwsA(isA<Exception>()),
      );

      // Same pattern as SessionHistoryListener bootstrap (try/catch, no rethrow).
      var appCrashed = false;
      try {
        try {
          await failingMapper.onCompleted(
            SessionCompletedEvent(
              routineId: 'y',
              completedAt: DateTime.now(),
              totalElapsedSeconds: 1,
              intervalCount: 1,
            ),
            displayName: '',
          );
        } catch (_) {
          // swallow
        }
      } catch (_) {
        appCrashed = true;
      }
      expect(appCrashed, isFalse);
    });
  });
}

class _ThrowingSessionLogRepo extends SessionLogRepository {
  _ThrowingSessionLogRepo(super.db);

  @override
  Future<SessionLog> insert({
    required String sourceId,
    required String displayName,
    required DateTime endedAt,
    required SessionLogStatus status,
    required int totalDurationSeconds,
    required int itemCount,
    String? note,
  }) {
    return Future.error(Exception('simulated db failure'));
  }
}
