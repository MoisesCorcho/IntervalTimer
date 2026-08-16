import 'package:drift/drift.dart';

@DataClassName('FavoriteRoutineRow')
class FavoriteRoutines extends Table {
  TextColumn get id => text()();
  TextColumn get targetId => text()();
  TextColumn get targetType => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {targetId, targetType},
      ];
}
