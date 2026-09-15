import 'package:drift/drift.dart';

@DataClassName('TemporaryPassRow')
class TemporaryPasses extends Table {
  TextColumn get id => text()();
  TextColumn get benefitType => text()(); // RewardedBenefit.name
  DateTimeColumn get grantedAtUtc => dateTime()();
  DateTimeColumn get expiresAtUtc => dateTime()();
  TextColumn get source => text().withDefault(const Constant('rewarded_ad'))();

  @override
  Set<Column> get primaryKey => {id};
}
