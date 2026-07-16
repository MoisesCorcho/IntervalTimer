import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';
import 'package:interval_timer/features/stats/domain/stats_service.dart';

SessionLog _log({
  required String localDate,
  required int seconds,
  String id = 'id',
  SessionLogStatus status = SessionLogStatus.completed,
}) {
  return SessionLog(
    id: id,
    sourceId: 'src',
    displayName: 'S',
    endedAt: DateTime.parse('${localDate}T12:00:00Z'),
    localDate: localDate,
    status: status,
    totalDurationSeconds: seconds,
    itemCount: 1,
  );
}

void main() {
  const service = StatsService();

  group('happy path — minutes, sessions, totals (R2, R3, R7)', () {
    test('aggregates week minutes, month sessions, totals from SessionLog only',
        () {
      // Fixed "now": Wednesday 2026-07-15 → ISO week Mon 13 – Sun 19
      final now = DateTime(2026, 7, 15);
      final focusedMonth = DateTime(2026, 7);

      final logs = [
        _log(id: '1', localDate: '2026-07-14', seconds: 90), // 1 min week
        _log(id: '2', localDate: '2026-07-15', seconds: 120), // +2 min week
        _log(id: '3', localDate: '2026-06-30', seconds: 600), // prev month
        _log(
          id: '4',
          localDate: '2026-07-01',
          seconds: 60,
          status: SessionLogStatus.aborted,
        ),
      ];

      final summary = service.summarize(
        logs,
        focusedMonth: focusedMonth,
        now: now,
        weightKg: 70,
        isWeightEstimated: true,
      );

      // week: 90+120 = 210s → floor 3 min
      expect(summary.weekMinutes, 3);
      // July logs: 1,2,4 → 3 sessions
      expect(summary.monthSessionCount, 3);
      // total seconds 90+120+600+60 = 870 → floor 14 min
      expect(summary.totalMinutes, 14);
      expect(summary.totalSessionCount, 4);
      expect(summary.isWeightEstimated, isTrue);
      expect(summary.weightKgUsed, 70);
    });
  });

  group('streak (R6, R10)', () {
    test('today with activity anchors on today', () {
      final now = DateTime(2026, 7, 15, 18);
      final logs = [
        _log(localDate: '2026-07-15', seconds: 60),
        _log(localDate: '2026-07-14', seconds: 60),
        _log(localDate: '2026-07-13', seconds: 60),
      ];
      expect(service.currentStreak(logs, now: now), 3);
    });

    test('today empty + yesterday active anchors on yesterday', () {
      final now = DateTime(2026, 7, 15, 10);
      final logs = [
        _log(localDate: '2026-07-14', seconds: 60),
        _log(localDate: '2026-07-13', seconds: 60),
      ];
      expect(service.currentStreak(logs, now: now), 2);
    });

    test('gap breaks streak', () {
      final now = DateTime(2026, 7, 15);
      final logs = [
        _log(localDate: '2026-07-15', seconds: 60),
        // gap on 14
        _log(localDate: '2026-07-13', seconds: 60),
      ];
      expect(service.currentStreak(logs, now: now), 1);
    });

    test('no logs → streak 0', () {
      expect(service.currentStreak(const [], now: DateTime(2026, 7, 15)), 0);
    });

    test('neither today nor yesterday → streak 0', () {
      final now = DateTime(2026, 7, 15);
      final logs = [_log(localDate: '2026-07-12', seconds: 60)];
      expect(service.currentStreak(logs, now: now), 0);
    });
  });

  group('kcal (R5, R12)', () {
    test('MET × weight × hours', () {
      // 3600s = 1h → 8.0 * 70 * 1 = 560
      final log = _log(localDate: '2026-07-15', seconds: 3600);
      expect(
        service.estimatedKcalForSession(log, weightKg: 70),
        closeTo(560.0, 0.001),
      );

      final summary = service.summarize(
        [log],
        focusedMonth: DateTime(2026, 7),
        now: DateTime(2026, 7, 15),
        weightKg: kDefaultWeightKg,
        isWeightEstimated: true,
      );
      expect(summary.totalEstimatedKcal, 560);
      expect(summary.isWeightEstimated, isTrue);
      expect(summary.weightKgUsed, kDefaultWeightKg);
    });

    test('default weight 70 and estimated flag', () {
      final log = _log(localDate: '2026-07-15', seconds: 1800); // 0.5h
      // 8 * 70 * 0.5 = 280
      final summary = service.summarize(
        [log],
        focusedMonth: DateTime(2026, 7),
        now: DateTime(2026, 7, 15),
        weightKg: 70,
        isWeightEstimated: true,
      );
      expect(summary.totalEstimatedKcal, 280);
      expect(summary.isWeightEstimated, isTrue);
    });
  });

  group('series (R4)', () {
    test('weekSeries returns 7 bars Mon–Sun of ISO week', () {
      final now = DateTime(2026, 7, 15); // Wed
      // Mon 13 = 120s → 2 min; Wed 15 = 60s → 1 min
      final logs = [
        _log(localDate: '2026-07-13', seconds: 120),
        _log(localDate: '2026-07-15', seconds: 60),
      ];
      final series = service.weekSeries(logs, now: now);
      expect(series, hasLength(7));
      expect(series.first.localDate, '2026-07-13'); // Monday
      expect(series.last.localDate, '2026-07-19'); // Sunday
      expect(series[0].minutes, 2);
      expect(series[1].minutes, 0); // Tue
      expect(series[2].minutes, 1); // Wed
      expect(series[3].minutes, 0);
    });

    test('monthSeries returns one entry per day of focused month', () {
      final logs = [
        _log(localDate: '2026-02-01', seconds: 120),
        _log(localDate: '2026-02-28', seconds: 60),
        _log(localDate: '2026-03-01', seconds: 999),
      ];
      final series =
          service.monthSeries(logs, focusedMonth: DateTime(2026, 2));
      expect(series, hasLength(28));
      expect(series.first.localDate, '2026-02-01');
      expect(series.first.minutes, 2);
      expect(series.last.localDate, '2026-02-28');
      expect(series.last.minutes, 1);
    });
  });

  group('empty history (R10)', () {
    test('summarize empty → zeros', () {
      final summary = service.summarize(
        const [],
        focusedMonth: DateTime(2026, 7),
        now: DateTime(2026, 7, 15),
        weightKg: 70,
        isWeightEstimated: true,
      );
      expect(summary.currentStreakDays, 0);
      expect(summary.weekMinutes, 0);
      expect(summary.monthSessionCount, 0);
      expect(summary.totalMinutes, 0);
      expect(summary.totalSessionCount, 0);
      expect(summary.totalEstimatedKcal, 0);
    });
  });
}
