import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/tables/intervals_table.dart';
import 'package:interval_timer/data/local/tables/routines_table.dart';

@DataClassName('RoutineItemRow')
class RoutineItems extends Table {
  TextColumn get id => text()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get itemType => text()();
  TextColumn get intervalId =>
      text().nullable().references(Intervals, #id)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {routineId, position},
      ];
}