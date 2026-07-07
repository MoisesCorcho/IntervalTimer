import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/database.dart';

class PreferencesRepository {
  PreferencesRepository(this._db);

  final AppDatabase _db;

  static const activeWorkoutIdKey = 'active_workout_id';

  Future<String?> getString(String key) async {
    final row = await (_db.select(_db.appPreferences)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setString(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.appPreferences)..where((t) => t.key.equals(key)))
          .go();
      return;
    }

    await _db.into(_db.appPreferences).insertOnConflictUpdate(
          AppPreferencesCompanion(
            key: Value(key),
            value: Value(value),
          ),
        );
  }

  Future<String?> getActiveWorkoutId() => getString(activeWorkoutIdKey);

  Future<void> setActiveWorkoutId(String? workoutId) =>
      setString(activeWorkoutIdKey, workoutId);
}