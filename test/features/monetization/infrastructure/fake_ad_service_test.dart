import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/monetization/data/temporary_pass_repository.dart';
import 'package:interval_timer/features/monetization/domain/ad_reward_result.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/monetization/infrastructure/fake_ad_service.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late TemporaryPassRepository passRepo;
  late FakeAdService adService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    passRepo = TemporaryPassRepository(db, prefs);
    adService = FakeAdService(temporaryPassRepository: passRepo);
  });

  tearDown(() async {
    await db.close();
  });

  group('FakeAdService Rewarded Ads Tests', () {
    test('showRewardedAd returns success when ad is completed', () async {
      adService.isReady = true;
      adService.shouldUserCompleteAd = true;

      final result = await adService.showRewardedAd(RewardedBenefit.extraWorkoutSlot);
      expect(result.isSuccess, isTrue);
      expect(result.status, equals(AdRewardStatus.rewardEarned));
    });

    test('showRewardedAd returns userDismissedEarly when dismissed early', () async {
      adService.isReady = true;
      adService.shouldUserCompleteAd = false;

      final result = await adService.showRewardedAd(RewardedBenefit.proAudioPass);
      expect(result.isSuccess, isFalse);
      expect(result.status, equals(AdRewardStatus.userDismissedEarly));
    });

    test('showRewardedAd returns adNotAvailable when not ready', () async {
      adService.isReady = false;

      final result = await adService.showRewardedAd(RewardedBenefit.phaseColorsPass);
      expect(result.isSuccess, isFalse);
      expect(result.status, equals(AdRewardStatus.adNotAvailable));
    });
  });

  group('FakeAdService Interstitial Cooldown Tests', () {
    test('canShowInterstitial returns true on first launch', () async {
      final canShow = await adService.canShowInterstitial();
      expect(canShow, isTrue);
    });

    test('showInterstitialIfEligible enforces 10-minute cooldown', () async {
      final now = DateTime.utc(2026, 9, 15, 12, 0);

      // Show first interstitial
      await adService.showInterstitialIfEligible(referenceTimeUtc: now);

      // 5 minutes later (cooldown active)
      final fiveMinLater = now.add(const Duration(minutes: 5));
      final canShowAt5 = await adService.canShowInterstitial(referenceTimeUtc: fiveMinLater);
      expect(canShowAt5, isFalse);

      // 10 minutes later (cooldown expired)
      final tenMinLater = now.add(const Duration(minutes: 10));
      final canShowAt10 = await adService.canShowInterstitial(referenceTimeUtc: tenMinLater);
      expect(canShowAt10, isTrue);
    });
  });
}
