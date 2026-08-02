import 'package:drift/drift.dart';

@DataClassName('WorkoutRow')
class Workouts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  /// Global rounds for the whole workout sequence (1–99). Default 1.
  IntColumn get rounds => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}