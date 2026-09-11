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

  group('PreferencesRepository - Onboarding (F30)', () {
    test('hasSeenOnboarding returns default false when not set', () async {
      expect(await repo.hasSeenOnboarding(), isFalse);
    });

    test('setHasSeenOnboarding persists true and reads back correctly', () async {
      await repo.setHasSeenOnboarding(true);
      expect(await repo.hasSeenOnboarding(), isTrue);

      await repo.setHasSeenOnboarding(false);
      expect(await repo.hasSeenOnboarding(), isFalse);
    });

    test('watchHasSeenOnboarding emits initial and updated states reactively', () async {
      final emissions = <bool>[];
      final subscription = repo.watchHasSeenOnboarding().listen(emissions.add);

      await Future<void>.delayed(Duration.zero);
      await repo.setHasSeenOnboarding(true);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, containsAllInOrder([false, true]));
      await subscription.cancel();
    });
  });
}
