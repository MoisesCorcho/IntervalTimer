import 'package:drift/drift.dart';

@DataClassName('AppPreferenceRow')
class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}