import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:interval_timer/data/local/tables/intervals_table.dart';
import 'package:interval_timer/data/local/tables/routine_items_table.dart';
import 'package:interval_timer/data/local/tables/routines_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Intervals, Routines, RoutineItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

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
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'interval_timer.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}