import 'package:drift/drift.dart';

@DataClassName('AdMetadataRow')
class AdMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
