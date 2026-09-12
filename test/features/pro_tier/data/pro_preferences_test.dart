import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PreferencesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PreferencesRepository - Pro Tier (F06)', () {
    test('isProUser returns default false when not set (R1, R13)', () async {
      expect(await repo.isProUser(), isFalse);
    });

    test('setIsProUser persists true and false correctly in SQLite (R1, R13)', () async {
      await repo.setIsProUser(true);
      expect(await repo.isProUser(), isTrue);

      await repo.setIsProUser(false);
      expect(await repo.isProUser(), isFalse);
    });

    test('watchIsProUser emits initial and updated states reactively (R1, R6)', () async {
      final emissions = <bool>[];
      final subscription = repo.watchIsProUser().listen(emissions.add);

      await Future<void>.delayed(Duration.zero);
      await repo.setIsProUser(true);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, containsAllInOrder([false, true]));
      await subscription.cancel();
    });
  });
}
