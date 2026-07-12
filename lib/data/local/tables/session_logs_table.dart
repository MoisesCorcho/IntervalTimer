import 'package:drift/drift.dart';

@DataClassName('SessionLogRow')
class SessionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get sourceId => text()();
  TextColumn get displayName => text()();
  IntColumn get endedAt => integer()();
  TextColumn get localDate => text()();
  TextColumn get status => text()();
  IntColumn get totalDurationSeconds => integer()();
  IntColumn get itemCount => integer()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
