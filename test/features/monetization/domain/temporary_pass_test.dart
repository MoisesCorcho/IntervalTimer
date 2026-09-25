import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/monetization/domain/temporary_pass.dart';

void main() {
  group('TemporaryPass Entity Tests', () {
    final grantedAt = DateTime.utc(2026, 9, 15, 10, 0);
    final expiresAt = DateTime.utc(2026, 9, 16, 10, 0); // 24 hours later

    test('isExpired returns false when reference time is before expiresAt', () {
      final pass = TemporaryPass(
        id: 'pass-1',
        benefit: RewardedBenefit.extraWorkoutSlot,
        grantedAtUtc: grantedAt,
        expiresAtUtc: expiresAt,
      );

      final beforeExpiry = DateTime.utc(2026, 9, 16, 9, 59);
      expect(pass.isExpired(beforeExpiry), isFalse);
    });

    test('isExpired returns true when reference time is after expiresAt', () {
      final pass = TemporaryPass(
        id: 'pass-1',
        benefit: RewardedBenefit.extraWorkoutSlot,
        grantedAtUtc: grantedAt,
        expiresAtUtc: expiresAt,
      );

      final afterExpiry = DateTime.utc(2026, 9, 16, 10, 1);
      expect(pass.isExpired(afterExpiry), isTrue);
    });

    test('remainingTime returns accurate duration when not expired', () {
      final pass = TemporaryPass(
        id: 'pass-2',
        benefit: RewardedBenefit.proAudioPass,
        grantedAtUtc: grantedAt,
        expiresAtUtc: DateTime.utc(2026, 9, 15, 22, 0), // 12 hours
      );

      final currentTime = DateTime.utc(2026, 9, 15, 16, 0);
      expect(
        pass.remainingTime(currentTime),
        equals(const Duration(hours: 6)),
      );
    });

    test('remainingTime returns Duration.zero when expired', () {
      final pass = TemporaryPass(
        id: 'pass-3',
        benefit: RewardedBenefit.adFreePass,
        grantedAtUtc: grantedAt,
        expiresAtUtc: expiresAt,
      );

      final currentTime = DateTime.utc(2026, 9, 16, 12, 0);
      expect(pass.remainingTime(currentTime), equals(Duration.zero));
    });
  });

  group('RewardedBenefit Enum Tests', () {
    test('verifies exact default durations for all MVP benefits', () {
      expect(
        RewardedBenefit.extraWorkoutSlot.defaultDuration,
        equals(const Duration(hours: 24)),
      );
      expect(
        RewardedBenefit.proAudioPass.defaultDuration,
        equals(const Duration(hours: 12)),
      );
      expect(
        RewardedBenefit.phaseColorsPass.defaultDuration,
        equals(const Duration(hours: 24)),
      );
      expect(
        RewardedBenefit.bodyTrackingPass.defaultDuration,
        equals(const Duration(hours: 24)),
      );
      expect(
        RewardedBenefit.adFreePass.defaultDuration,
        equals(const Duration(hours: 24)),
      );
    });
  });
}
