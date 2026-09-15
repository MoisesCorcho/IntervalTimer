import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/monetization/data/temporary_pass_repository.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefsRepo;
  late TemporaryPassRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefsRepo = PreferencesRepository(db);
    repository = TemporaryPassRepository(db, prefsRepo);
  });

  tearDown(() async {
    await db.close();
  });

  group('TemporaryPassRepository Tests', () {
    test('grantPass inserts pass and hasActivePass returns true', () async {
      final now = DateTime.utc(2026, 9, 15, 12, 0);

      await repository.grantPass(
        benefit: RewardedBenefit.extraWorkoutSlot,
        duration: const Duration(hours: 24),
        referenceTimeUtc: now,
      );

      final hasPass = await repository.hasActivePass(
        RewardedBenefit.extraWorkoutSlot,
        referenceTimeUtc: now,
      );
      expect(hasPass, isTrue);

      final passes = await repository.getActivePasses(referenceTimeUtc: now);
      expect(passes.length, equals(1));
      expect(passes.first.benefit, equals(RewardedBenefit.extraWorkoutSlot));
      expect(passes.first.grantedAtUtc, equals(now));
      expect(passes.first.expiresAtUtc, equals(now.add(const Duration(hours: 24))));
    });

    test('hasActivePass returns false after expiration', () async {
      final now = DateTime.utc(2026, 9, 15, 12, 0);

      await repository.grantPass(
        benefit: RewardedBenefit.proAudioPass,
        duration: const Duration(hours: 12),
        referenceTimeUtc: now,
      );

      // 13 hours later
      final futureTime = now.add(const Duration(hours: 13));
      final hasPass = await repository.hasActivePass(
        RewardedBenefit.proAudioPass,
        referenceTimeUtc: futureTime,
      );
      expect(hasPass, isFalse);

      final activePasses = await repository.getActivePasses(
        referenceTimeUtc: futureTime,
      );
      expect(activePasses, isEmpty);
    });

    test('watchActivePasses emits reactive updates', () async {
      final now = DateTime.utc(2026, 9, 15, 12, 0);

      final expectation = expectLater(
        repository.watchActivePasses(referenceTimeUtc: now),
        emitsInOrder([
          isEmpty,
          hasLength(1),
        ]),
      );

      await Future<void>.delayed(Duration.zero);

      // Trigger insert
      await repository.grantPass(
        benefit: RewardedBenefit.adFreePass,
        duration: const Duration(hours: 24),
        referenceTimeUtc: now,
      );

      await expectation;
    });

    test('purgeExpiredPasses deletes outdated passes', () async {
      final now = DateTime.utc(2026, 9, 15, 12, 0);

      await repository.grantPass(
        benefit: RewardedBenefit.phaseColorsPass,
        duration: const Duration(hours: 24),
        referenceTimeUtc: now,
      );

      // 25 hours later
      final futureTime = now.add(const Duration(hours: 25));
      await repository.purgeExpiredPasses(referenceTimeUtc: futureTime);

      final allRows = await db.select(db.temporaryPasses).get();
      expect(allRows, isEmpty);
    });

    test('clock tampering detection flags when time moves backwards', () async {
      final legitTime = DateTime.utc(2026, 9, 15, 12, 0);
      await repository.recordVerifiedTimestamp(legitTime);

      // Manipulated time in the past
      final manipulatedPast = DateTime.utc(2026, 9, 15, 10, 0);
      final isTampered = await repository.isClockTampered(manipulatedPast);
      expect(isTampered, isTrue);

      // Time moving forward normally
      final forwardTime = DateTime.utc(2026, 9, 15, 13, 0);
      final isTamperedForward = await repository.isClockTampered(forwardTime);
      expect(isTamperedForward, isFalse);
    });

    test('clock tampering invalidates hasActivePass and getActivePasses', () async {
      final now = DateTime.utc(2026, 9, 15, 12, 0);
      await repository.grantPass(
        benefit: RewardedBenefit.extraWorkoutSlot,
        duration: const Duration(hours: 24),
        referenceTimeUtc: now,
      );

      expect(
        await repository.hasActivePass(
          RewardedBenefit.extraWorkoutSlot,
          referenceTimeUtc: now,
        ),
        isTrue,
      );

      // Manipulate clock backward
      final manipulatedPast = DateTime.utc(2026, 9, 15, 10, 0);
      expect(
        await repository.hasActivePass(
          RewardedBenefit.extraWorkoutSlot,
          referenceTimeUtc: manipulatedPast,
        ),
        isFalse,
      );
      expect(
        await repository.getActivePasses(referenceTimeUtc: manipulatedPast),
        isEmpty,
      );
    });
  });
}
