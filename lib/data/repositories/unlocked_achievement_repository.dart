import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/features/achievements/domain/unlocked_achievement.dart';

class UnlockedAchievementRepository {
  UnlockedAchievementRepository(this._db);

  final AppDatabase _db;

  Stream<List<UnlockedAchievement>> watchAll() {
    return (_db.select(_db.unlockedAchievements)
          ..orderBy([(t) => OrderingTerm.asc(t.unlockedAt)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  Future<List<UnlockedAchievement>> getAll() async {
    final rows = await (_db.select(_db.unlockedAchievements)
          ..orderBy([(t) => OrderingTerm.asc(t.unlockedAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<Set<String>> getUnlockedIds() async {
    final rows = await _db.select(_db.unlockedAchievements).get();
    return rows.map((r) => r.achievementId).toSet();
  }

  /// Inserts unlock if missing. Returns `true` when a new row was written (R11).
  ///
  /// Uses an existence check + insert so we never overwrite [unlockedAt].
  Future<bool> insertIgnore({
    required String achievementId,
    required DateTime unlockedAt,
  }) async {
    final existing = await (_db.select(_db.unlockedAchievements)
          ..where((t) => t.achievementId.equals(achievementId)))
        .getSingleOrNull();
    if (existing != null) return false;

    await _db.into(_db.unlockedAchievements).insert(
          UnlockedAchievementsCompanion.insert(
            achievementId: achievementId,
            unlockedAt: unlockedAt.toUtc().millisecondsSinceEpoch,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    // Confirm insert won the race (idempotent if parallel ignore).
    final after = await (_db.select(_db.unlockedAchievements)
          ..where((t) => t.achievementId.equals(achievementId)))
        .getSingleOrNull();
    if (after == null) return false;
    return after.unlockedAt == unlockedAt.toUtc().millisecondsSinceEpoch;
  }

  UnlockedAchievement _fromRow(UnlockedAchievementRow row) {
    return UnlockedAchievement(
      achievementId: row.achievementId,
      unlockedAt:
          DateTime.fromMillisecondsSinceEpoch(row.unlockedAt, isUtc: true),
    );
  }
}
