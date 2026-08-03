import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/achievements/domain/achievement_catalog.dart';

void main() {
  group('achievement catalog (R1)', () {
    test('has at least 10 entries and 12 required ids are unique', () {
      expect(kAchievementCatalog.length, greaterThanOrEqualTo(10));
      expect(kAchievementCatalog.length, 12);

      final ids = kAchievementCatalog.map((e) => e.id).toList();
      expect(ids.toSet(), hasLength(ids.length));

      const required = {
        'first_session',
        'sessions_10',
        'sessions_25',
        'sessions_50',
        'sessions_100',
        'streak_3',
        'streak_7',
        'streak_14',
        'streak_30',
        'minutes_60',
        'minutes_300',
        'minutes_1000',
      };
      expect(ids.toSet(), required);
    });
  });
}
