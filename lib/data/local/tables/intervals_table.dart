import 'package:drift/drift.dart';

@DataClassName('IntervalRow')
class Intervals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get durationSeconds => integer()();
  IntColumn get colorArgb => integer()();
  TextColumn get type => text()();

  @override
  Set<Column> get primaryKey => {id};
}