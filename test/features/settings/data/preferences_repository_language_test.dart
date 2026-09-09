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

  group('PreferencesRepository - Language (F28)', () {
    test('returns default "system" when not set', () async {
      expect(await repo.getAppLanguage(), 'system');
    });

    test('sets and gets valid languages ("es", "en", "system")', () async {
      await repo.setAppLanguage('es');
      expect(await repo.getAppLanguage(), 'es');

      await repo.setAppLanguage('en');
      expect(await repo.getAppLanguage(), 'en');

      await repo.setAppLanguage('system');
      expect(await repo.getAppLanguage(), 'system');
    });

    test('falls back to "system" on invalid language string', () async {
      await repo.setAppLanguage('invalid_lang');
      expect(await repo.getAppLanguage(), 'system');
    });

    test('watchAppLanguage emits updates reactively', () async {
      final emissions = <String>[];
      final subscription = repo.watchAppLanguage().listen(emissions.add);

      await Future<void>.delayed(Duration.zero);
      await repo.setAppLanguage('es');
      await Future<void>.delayed(Duration.zero);
      await repo.setAppLanguage('en');
      await Future<void>.delayed(Duration.zero);

      expect(emissions, containsAllInOrder(['system', 'es', 'en']));
      await subscription.cancel();
    });
  });
}
