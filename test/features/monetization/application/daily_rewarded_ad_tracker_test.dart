import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/monetization/application/daily_rewarded_ad_tracker.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late DailyRewardedAdTracker tracker;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    tracker = DailyRewardedAdTracker(prefs);
  });

  tearDown(() async {
    await db.close();
  });

  group('DailyRewardedAdTracker Tests', () {
    test('canWatchAd returns true on clean state', () async {
      final canWatch = await tracker.canWatchAd();
      expect(canWatch, isTrue);
      expect(await tracker.getDailyCount(), equals(0));
      expect(await tracker.isCooldownActive(), isFalse);
    });

    test('enforces 15-minute cooldown between videos', () async {
      final firstAdTime = DateTime.utc(2026, 9, 15, 10, 0);
      await tracker.recordAdWatched(firstAdTime);

      expect(await tracker.getDailyCount(referenceTimeUtc: firstAdTime), equals(1));

      // 5 minutes later: cooldown is active
      final fiveMinLater = firstAdTime.add(const Duration(minutes: 5));
      expect(await tracker.isCooldownActive(referenceTimeUtc: fiveMinLater), isTrue);
      expect(await tracker.canWatchAd(referenceTimeUtc: fiveMinLater), isFalse);

      // 16 minutes later: cooldown expired, can watch 2nd ad
      final sixteenMinLater = firstAdTime.add(const Duration(minutes: 16));
      expect(await tracker.isCooldownActive(referenceTimeUtc: sixteenMinLater), isFalse);
      expect(await tracker.canWatchAd(referenceTimeUtc: sixteenMinLater), isTrue);
    });

    test('enforces daily cap of 2 videos every 24 hours', () async {
      final firstAdTime = DateTime.utc(2026, 9, 15, 10, 0);
      await tracker.recordAdWatched(firstAdTime);

      final secondAdTime = firstAdTime.add(const Duration(minutes: 30));
      await tracker.recordAdWatched(secondAdTime);

      // Daily count is 2
      expect(await tracker.getDailyCount(referenceTimeUtc: secondAdTime), equals(2));

      // Even after 1 hour (cooldown passed), daily cap blocks 3rd video
      final oneHourLater = secondAdTime.add(const Duration(hours: 1));
      expect(await tracker.canWatchAd(referenceTimeUtc: oneHourLater), isFalse);

      // 24 hours and 10 minutes after first ad (first ad expired, second ad at +30m remains in window)
      final twentyFourHoursTenMinLater = firstAdTime.add(const Duration(hours: 24, minutes: 10));
      expect(await tracker.getDailyCount(referenceTimeUtc: twentyFourHoursTenMinLater), equals(1));
      expect(await tracker.canWatchAd(referenceTimeUtc: twentyFourHoursTenMinLater), isTrue);
    });

    test('clock manipulation backwards does not bypass cooldown or daily cap', () async {
      final adTime = DateTime.utc(2026, 9, 15, 12, 0);
      await tracker.recordAdWatched(adTime);

      // Manipulate clock to 1 hour before the ad
      final manipulatedPast = DateTime.utc(2026, 9, 15, 11, 0);
      expect(await tracker.isCooldownActive(referenceTimeUtc: manipulatedPast), isTrue);
      expect(await tracker.canWatchAd(referenceTimeUtc: manipulatedPast), isFalse);
      expect(await tracker.getDailyCount(referenceTimeUtc: manipulatedPast), equals(1));
    });
  });
}
