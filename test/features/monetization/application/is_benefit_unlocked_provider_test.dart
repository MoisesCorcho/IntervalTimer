import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/monetization/application/monetization_providers.dart';
import 'package:interval_timer/features/monetization/data/temporary_pass_repository.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late TemporaryPassRepository passRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    passRepo = TemporaryPassRepository(db, prefs);
  });

  tearDown(() async {
    await db.close();
  });

  group('isBenefitUnlockedProvider Tests', () {
    test('returns true for all benefits when user is Pro', () async {
      final container = ProviderContainer(
        overrides: [
          isProUserProvider.overrideWith((ref) => Stream.value(true)),
          temporaryPassRepositoryProvider.overrideWithValue(passRepo),
        ],
      );

      await container.read(isProUserProvider.future);

      for (final benefit in RewardedBenefit.values) {
        expect(
          container.read(isBenefitUnlockedProvider(benefit)),
          isTrue,
        );
      }
    });

    test('returns false when Free user has no active pass', () {
      final container = ProviderContainer(
        overrides: [
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
          temporaryPassRepositoryProvider.overrideWithValue(passRepo),
        ],
      );

      for (final benefit in RewardedBenefit.values) {
        expect(
          container.read(isBenefitUnlockedProvider(benefit)),
          isFalse,
        );
      }
    });

    test('returns true when Free user has an active temporary pass for that benefit', () async {
      final now = DateTime.utc(2026, 9, 15, 12, 0);
      await passRepo.grantPass(
        benefit: RewardedBenefit.proAudioPass,
        duration: const Duration(hours: 12),
        referenceTimeUtc: now,
      );

      final container = ProviderContainer(
        overrides: [
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
          temporaryPassRepositoryProvider.overrideWithValue(passRepo),
        ],
      );

      // Wait for stream to emit active passes
      await container.read(activeTemporaryPassesProvider.future);

      expect(
        container.read(isBenefitUnlockedProvider(RewardedBenefit.proAudioPass)),
        isTrue,
      );

      // Other benefits without pass remain locked
      expect(
        container.read(isBenefitUnlockedProvider(RewardedBenefit.extraWorkoutSlot)),
        isFalse,
      );
    });

    test('canCreateWorkoutProvider allows 4th workout when extraWorkoutSlot pass is active', () async {
      final now = DateTime.utc(2026, 9, 15, 12, 0);

      final container = ProviderContainer(
        overrides: [
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
          temporaryPassRepositoryProvider.overrideWithValue(passRepo),
          customWorkoutsCountProvider.overrideWithValue(3), // Already at limit of 3
        ],
      );

      // Without pass: cannot create 4th workout
      expect(container.read(canCreateWorkoutProvider), isFalse);

      // Grant extraWorkoutSlot pass
      await passRepo.grantPass(
        benefit: RewardedBenefit.extraWorkoutSlot,
        duration: const Duration(hours: 24),
        referenceTimeUtc: now,
      );

      // Await active passes stream update
      await container.read(activeTemporaryPassesProvider.future);

      // With active pass: can create 4th workout!
      expect(container.read(canCreateWorkoutProvider), isTrue);

      // But when already at 4: cannot create 5th workout
      final containerAt4 = ProviderContainer(
        overrides: [
          isProUserProvider.overrideWith((ref) => Stream.value(false)),
          temporaryPassRepositoryProvider.overrideWithValue(passRepo),
          customWorkoutsCountProvider.overrideWithValue(4),
        ],
      );
      await containerAt4.read(activeTemporaryPassesProvider.future);
      expect(containerAt4.read(canCreateWorkoutProvider), isFalse);
    });
  });
}
