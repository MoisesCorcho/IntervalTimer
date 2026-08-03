import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/unlocked_achievement_repository.dart';

void main() {
  late AppDatabase db;
  late UnlockedAchievementRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = UnlockedAchievementRepository(db);
  });

  tearDown(() async => db.close());

  group('UnlockedAchievementRepository (R6, R11)', () {
    test('insertIgnore creates row once and keeps original unlockedAt',
        () async {
      final t1 = DateTime.utc(2026, 7, 1, 10);
      final t2 = DateTime.utc(2026, 7, 2, 12);

      final first = await repo.insertIgnore(
        achievementId: 'first_session',
        unlockedAt: t1,
      );
      final second = await repo.insertIgnore(
        achievementId: 'first_session',
        unlockedAt: t2,
      );

      expect(first, isTrue);
      expect(second, isFalse);

      final all = await repo.getAll();
      expect(all, hasLength(1));
      expect(all.first.achievementId, 'first_session');
      expect(all.first.unlockedAt, t1);
    });

    test('getUnlockedIds returns set of ids', () async {
      await repo.insertIgnore(
        achievementId: 'first_session',
        unlockedAt: DateTime.utc(2026, 7, 1),
      );
      await repo.insertIgnore(
        achievementId: 'streak_3',
        unlockedAt: DateTime.utc(2026, 7, 2),
      );

      final ids = await repo.getUnlockedIds();
      expect(ids, {'first_session', 'streak_3'});
    });
  });
}
