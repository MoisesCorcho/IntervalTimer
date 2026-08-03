import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:interval_timer/data/local/tables/app_preferences_table.dart';
import 'package:interval_timer/data/local/tables/body_measurements_table.dart';
import 'package:interval_timer/data/local/tables/intervals_table.dart';
import 'package:interval_timer/data/local/tables/routine_items_table.dart';
import 'package:interval_timer/data/local/tables/routines_table.dart';
import 'package:interval_timer/data/local/tables/session_logs_table.dart';
import 'package:interval_timer/data/local/tables/unlocked_achievements_table.dart';
import 'package:interval_timer/data/local/tables/workout_exercises_table.dart';
import 'package:interval_timer/data/local/tables/workouts_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Intervals,
    Routines,
    RoutineItems,
    Workouts,
    WorkoutExercises,
    AppPreferences,
    SessionLogs,
    BodyMeasurements,
    UnlockedAchievements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(workouts);
            await migrator.createTable(workoutExercises);
          }
          if (from < 3) {
            await migrator.createTable(appPreferences);
          }
          if (from < 4) {
            await migrator.addColumn(
              workoutExercises,
              workoutExercises.restAfterExerciseSeconds,
            );
          }
          if (from < 5) {
            await migrator.createTable(sessionLogs);
          }
          if (from < 6) {
            await migrator.addColumn(intervals, intervals.announceText);
          }
          if (from < 7) {
            await migrator.addColumn(workouts, workouts.rounds);
          }
          if (from < 8) {
            await migrator.createTable(bodyMeasurements);
          }
          if (from < 9) {
            await migrator.createTable(unlockedAchievements);
          }
        },
      );

  Future<List<IntervalRow>> getAllIntervals() => select(intervals).get();

  Future<List<RoutineRow>> getAllRoutines() => select(routines).get();

  Future<List<RoutineItemRow>> getRoutineItems(String routineId) {
    return (select(routineItems)
          ..where((t) => t.routineId.equals(routineId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
  }

  Future<void> replaceRoutineData({
    required RoutineRow routine,
    required List<IntervalRow> intervalRows,
    required List<RoutineItemRow> itemRows,
  }) async {
    await transaction(() async {
      await delete(routineItems).go();
      await delete(intervals).go();
      await delete(routines).go();

      await into(routines).insert(routine);
      for (final interval in intervalRows) {
        await into(intervals).insert(interval);
      }
      for (final item in itemRows) {
        await into(routineItems).insert(item);
      }
    });
  }

  Future<List<WorkoutRow>> getAllWorkoutRows() {
    return (select(workouts)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Future<WorkoutRow?> getWorkoutRow(String id) {
    return (select(workouts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<WorkoutExerciseRow>> getWorkoutExerciseRows(String workoutId) {
    return (select(workoutExercises)
          ..where((t) => t.workoutId.equals(workoutId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
  }
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'interval_timer.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}