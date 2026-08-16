import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/models/favorite_routine.dart';
import 'package:uuid/uuid.dart';

abstract class FavoriteRepository {
  Stream<Set<String>> watchFavoriteTargetIds();
  Stream<List<FavoriteRoutine>> watchAllFavorites();
  Future<List<FavoriteRoutine>> getAllFavorites();
  Future<bool> isFavorite(String targetId, FavoriteTargetType targetType);
  Future<bool> toggleFavorite({
    required String targetId,
    required FavoriteTargetType targetType,
  });
  Future<void> deleteByTargetId(String targetId);
}

class DriftFavoriteRepository implements FavoriteRepository {
  DriftFavoriteRepository(this._db, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  @override
  Stream<Set<String>> watchFavoriteTargetIds() {
    return (_db.select(_db.favoriteRoutines)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.targetId).toSet());
  }

  @override
  Stream<List<FavoriteRoutine>> watchAllFavorites() {
    return (_db.select(_db.favoriteRoutines)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  @override
  Future<List<FavoriteRoutine>> getAllFavorites() async {
    final rows = await (_db.select(_db.favoriteRoutines)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<bool> isFavorite(String targetId, FavoriteTargetType targetType) async {
    final row = await (_db.select(_db.favoriteRoutines)
          ..where(
            (t) =>
                t.targetId.equals(targetId) &
                t.targetType.equals(targetType.name),
          ))
        .getSingleOrNull();
    return row != null;
  }

  @override
  Future<bool> toggleFavorite({
    required String targetId,
    required FavoriteTargetType targetType,
  }) async {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.favoriteRoutines)
            ..where(
              (t) =>
                  t.targetId.equals(targetId) &
                  t.targetType.equals(targetType.name),
            ))
          .getSingleOrNull();

      if (existing != null) {
        await (_db.delete(_db.favoriteRoutines)
              ..where((t) => t.id.equals(existing.id)))
            .go();
        return false;
      } else {
        final id = _uuid.v4();
        final now = DateTime.now().toUtc();
        await _db.into(_db.favoriteRoutines).insert(
              FavoriteRoutineRow(
                id: id,
                targetId: targetId,
                targetType: targetType.name,
                createdAt: now.millisecondsSinceEpoch,
              ),
              mode: InsertMode.insertOrReplace,
            );
        return true;
      }
    });
  }

  @override
  Future<void> deleteByTargetId(String targetId) async {
    await (_db.delete(_db.favoriteRoutines)
          ..where((t) => t.targetId.equals(targetId)))
        .go();
  }

  FavoriteRoutine _fromRow(FavoriteRoutineRow row) {
    return FavoriteRoutine(
      id: row.id,
      targetId: row.targetId,
      targetType: row.targetType == FavoriteTargetType.preset.name
          ? FavoriteTargetType.preset
          : FavoriteTargetType.workout,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
    );
  }
}
