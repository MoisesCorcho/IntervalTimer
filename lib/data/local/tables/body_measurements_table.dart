import 'package:drift/drift.dart';

@DataClassName('BodyMeasurementRow')
class BodyMeasurements extends Table {
  TextColumn get id => text()();
  TextColumn get localDate => text()();
  RealColumn get weightKg => real()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get armCm => real().nullable()();
  RealColumn get legCm => real().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {localDate},
      ];
}
