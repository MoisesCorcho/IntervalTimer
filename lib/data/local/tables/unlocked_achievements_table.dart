import 'package:drift/drift.dart';

@DataClassName('UnlockedAchievementRow')
class UnlockedAchievements extends Table {
  TextColumn get achievementId => text()();
  IntColumn get unlockedAt => integer()();

  @override
  Set<Column> get primaryKey => {achievementId};
}
