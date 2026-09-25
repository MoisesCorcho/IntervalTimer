import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/monetization/application/daily_rewarded_ad_tracker.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/data/temporary_pass_repository.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/monetization/infrastructure/fake_ad_service.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late TemporaryPassRepository passRepo;
  late FakeAdService fakeAdService;
  late DailyRewardedAdTracker tracker;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    passRepo = TemporaryPassRepository(db, prefs);
    fakeAdService = FakeAdService(temporaryPassRepository: passRepo);
    tracker = DailyRewardedAdTracker(prefs);
  });

  tearDown(() async {
    await db.close();
  });

  group('MonetizationController Tests', () {
    test('requestRewardedUnlock grants pass on completed ad', () async {
      final container = ProviderContainer(
        overrides: [
          temporaryPassRepositoryProvider.overrideWithValue(passRepo),
          adServiceProvider.overrideWithValue(fakeAdService),
          dailyRewardedAdTrackerProvider.overrideWithValue(tracker),
        ],
      );

      fakeAdService.isReady = true;
      fakeAdService.shouldUserCompleteAd = true;

      final controller = container.read(monetizationControllerProvider.notifier);
      final success = await controller.requestRewardedUnlock(RewardedBenefit.extraWorkoutSlot);

      expect(success, isTrue);
      expect(container.read(monetizationControllerProvider).lastGrantedPass, isNotNull);
      expect(await passRepo.hasActivePass(RewardedBenefit.extraWorkoutSlot), isTrue);
      expect(await tracker.getDailyCount(), equals(1));
    });

    test('requestRewardedUnlock sets error message on early dismissal', () async {
      final container = ProviderContainer(
        overrides: [
          temporaryPassRepositoryProvider.overrideWithValue(passRepo),
          adServiceProvider.overrideWithValue(fakeAdService),
          dailyRewardedAdTrackerProvider.overrideWithValue(tracker),
        ],
      );

      fakeAdService.isReady = true;
      fakeAdService.shouldUserCompleteAd = false;

      final controller = container.read(monetizationControllerProvider.notifier);
      final success = await controller.requestRewardedUnlock(RewardedBenefit.proAudioPass);

      expect(success, isFalse);
      expect(container.read(monetizationControllerProvider).lastGrantedPass, isNull);
      expect(container.read(monetizationControllerProvider).errorMessage, isNotNull);
      expect(await passRepo.hasActivePass(RewardedBenefit.proAudioPass), isFalse);
    });

    test('requestRewardedUnlock blocks when daily cap reached', () async {
      final now = DateTime.now().toUtc();
      await tracker.recordAdWatched(now.subtract(const Duration(hours: 1)));
      await tracker.recordAdWatched(now.subtract(const Duration(minutes: 20)));

      final container = ProviderContainer(
        overrides: [
          temporaryPassRepositoryProvider.overrideWithValue(passRepo),
          adServiceProvider.overrideWithValue(fakeAdService),
          dailyRewardedAdTrackerProvider.overrideWithValue(tracker),
        ],
      );

      final controller = container.read(monetizationControllerProvider.notifier);
      final success = await controller.requestRewardedUnlock(RewardedBenefit.phaseColorsPass);

      expect(success, isFalse);
      expect(container.read(monetizationControllerProvider).errorMessage, contains('Límite diario'));
    });
  });
}
