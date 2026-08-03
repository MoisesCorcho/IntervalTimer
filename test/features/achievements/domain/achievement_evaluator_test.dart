import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/data/models/session_log_status.dart';
import 'package:interval_timer/features/achievements/domain/achievement_catalog.dart';
import 'package:interval_timer/features/achievements/domain/achievement_evaluator.dart';
import 'package:interval_timer/features/achievements/domain/unlocked_achievement.dart';
import 'package:interval_timer/features/stats/domain/stats_service.dart';

SessionLog _log({
  required String id,
  required String localDate,
  required int seconds,
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
  const evaluator = AchievementEvaluator();
  final now = DateTime(2026, 7, 15, 18);

  group('session counts (R4, R5)', () {
    test('0 completed unlocks nothing for session milestones', () {
      final newly = evaluator.evaluate(const [], {}, now: now);
      expect(newly, isEmpty);
    });

    test('1 completed unlocks first_session only', () {
      final logs = [_log(id: '1', localDate: '2026-07-15', seconds: 60)];
      final newly = evaluator.evaluate(logs, {}, now: now);
      expect(newly.map((e) => e.id), contains('first_session'));
      expect(newly.map((e) => e.id), isNot(contains('sessions_10')));
    });

    test('aborted sessions do not count toward sessions_*', () {
      final logs = List.generate(
        10,
        (i) => _log(
          id: 'a$i',
          localDate: '2026-07-0${(i % 9) + 1}',
          seconds: 60,
          status: SessionLogStatus.aborted,
        ),
      );
      final newly = evaluator.evaluate(logs, {}, now: now);
      expect(newly.map((e) => e.id), isNot(contains('first_session')));
      expect(newly.map((e) => e.id), isNot(contains('sessions_10')));
    });

    test('10 completed unlocks first_session and sessions_10', () {
      final logs = List.generate(
        10,
        (i) => _log(
          id: '$i',
          localDate: '2026-07-${(i + 1).toString().padLeft(2, '0')}',
          seconds: 60,
        ),
      );
      final newly = evaluator.evaluate(logs, {}, now: now);
      final ids = newly.map((e) => e.id).toSet();
      expect(ids, containsAll(['first_session', 'sessions_10']));
      expect(ids, isNot(contains('sessions_25')));
    });
  });

  group('minutes (R5)', () {
    test('60 minutes of completed unlocks minutes_60', () {
      // 60 * 60 = 3600 seconds → 60 minutes
      final logs = [
        _log(id: '1', localDate: '2026-07-15', seconds: 3600),
      ];
      final newly = evaluator.evaluate(logs, {}, now: now);
      expect(newly.map((e) => e.id), contains('minutes_60'));
      expect(newly.map((e) => e.id), isNot(contains('minutes_300')));
    });

    test('300 minutes unlocks minutes_60 and minutes_300', () {
      final logs = [
        _log(id: '1', localDate: '2026-07-14', seconds: 9000), // 150 min
        _log(id: '2', localDate: '2026-07-15', seconds: 9000), // 150 min
      ];
      final newly = evaluator.evaluate(logs, {}, now: now);
      final ids = newly.map((e) => e.id).toSet();
      expect(ids, containsAll(['minutes_60', 'minutes_300']));
      expect(ids, isNot(contains('minutes_1000')));
    });

    test('aborted duration does not count toward minutes', () {
      final logs = [
        _log(
          id: '1',
          localDate: '2026-07-15',
          seconds: 10000,
          status: SessionLogStatus.aborted,
        ),
      ];
      final newly = evaluator.evaluate(logs, {}, now: now);
      expect(newly.map((e) => e.id), isNot(contains('minutes_60')));
    });
  });

  group('streak aligned with F12 (R5)', () {
    test('3 consecutive days including today unlocks streak_3', () {
      final logs = [
        _log(id: '1', localDate: '2026-07-13', seconds: 60),
        _log(id: '2', localDate: '2026-07-14', seconds: 60),
        _log(id: '3', localDate: '2026-07-15', seconds: 60),
      ];
      expect(const StatsService().currentStreak(logs, now: now), 3);
      final newly = evaluator.evaluate(logs, {}, now: now);
      expect(newly.map((e) => e.id), contains('streak_3'));
      expect(newly.map((e) => e.id), isNot(contains('streak_7')));
    });

    test('aborted day counts for streak anchor (F12 R6)', () {
      // All aborted: no session-count unlocks, but streak still applies.
      final logs = [
        _log(
          id: '1',
          localDate: '2026-07-15',
          seconds: 30,
          status: SessionLogStatus.aborted,
        ),
        _log(
          id: '2',
          localDate: '2026-07-14',
          seconds: 30,
          status: SessionLogStatus.aborted,
        ),
        _log(
          id: '3',
          localDate: '2026-07-13',
          seconds: 30,
          status: SessionLogStatus.aborted,
        ),
      ];
      final newly = evaluator.evaluate(logs, {}, now: now);
      expect(newly.map((e) => e.id), contains('streak_3'));
      expect(newly.map((e) => e.id), isNot(contains('first_session')));
    });
  });

  group('immutability progress (R6)', () {
    test('unlocked stays unlocked in progress even if logs empty', () {
      final unlocks = [
        UnlockedAchievement(
          achievementId: 'first_session',
          unlockedAt: DateTime.utc(2026, 1, 1),
        ),
        UnlockedAchievement(
          achievementId: 'sessions_10',
          unlockedAt: DateTime.utc(2026, 2, 1),
        ),
      ];
      final progress = evaluator.buildProgress(const [], unlocks, now: now);
      final first = progress.firstWhere((p) => p.def.id == 'first_session');
      final ten = progress.firstWhere((p) => p.def.id == 'sessions_10');
      expect(first.isUnlocked, isTrue);
      expect(ten.isUnlocked, isTrue);
      expect(first.current, first.target);
    });
  });

  group('already unlocked skipped (R11 prep)', () {
    test('evaluate does not re-propose unlocked ids', () {
      final logs = List.generate(
        10,
        (i) => _log(
          id: '$i',
          localDate: '2026-07-${(i + 1).toString().padLeft(2, '0')}',
          seconds: 60,
        ),
      );
      final newly = evaluator.evaluate(
        logs,
        {'first_session', 'sessions_10'},
        now: now,
      );
      expect(newly.map((e) => e.id), isNot(contains('first_session')));
      expect(newly.map((e) => e.id), isNot(contains('sessions_10')));
    });
  });

  group('multi unlock (R7)', () {
    test('one evaluate can return multiple new achievements', () {
      // first session + 60 minutes in one log of 3600s
      final logs = [
        _log(id: '1', localDate: '2026-07-15', seconds: 3600),
      ];
      final newly = evaluator.evaluate(logs, {}, now: now);
      expect(newly.length, greaterThanOrEqualTo(2));
      final ids = newly.map((e) => e.id).toSet();
      expect(ids, containsAll(['first_session', 'minutes_60']));
    });
  });

  test('catalog size matches evaluator catalog', () {
    expect(evaluator.catalog, same(kAchievementCatalog));
  });
}
