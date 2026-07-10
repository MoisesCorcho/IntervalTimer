import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/database.dart';

class PreferencesRepository {
  PreferencesRepository(this._db);

  final AppDatabase _db;

  static const activeWorkoutIdKey = 'active_workout_id';
  static const prepSecondsKey = 'prep_seconds';
  static const defaultPrepSeconds = 10;
  static const minPrepSeconds = 0;
  static const maxPrepSeconds = 60;

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

  Future<int?> getInt(String key) async {
    final raw = await getString(key);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<void> setInt(String key, int value) =>
      setString(key, value.toString());

  Future<String?> getActiveWorkoutId() => getString(activeWorkoutIdKey);

  Future<void> setActiveWorkoutId(String? workoutId) =>
      setString(activeWorkoutIdKey, workoutId);

  /// F35: preparation seconds before first interval (default 10, range 0–60).
  Future<int> getPrepSeconds() async {
    final value = await getInt(prepSecondsKey);
    if (value == null) return defaultPrepSeconds;
    return value.clamp(minPrepSeconds, maxPrepSeconds);
  }

  Future<void> setPrepSeconds(int value) async {
    final clamped = value.clamp(minPrepSeconds, maxPrepSeconds);
    await setInt(prepSecondsKey, clamped);
  }
}