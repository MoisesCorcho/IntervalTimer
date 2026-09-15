import 'package:interval_timer/features/monetization/data/temporary_pass_repository.dart';
import 'package:interval_timer/features/monetization/domain/ad_reward_result.dart';
import 'package:interval_timer/features/monetization/domain/ad_service.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';

/// Implementación simulada de [AdService] para desarrollo, CI y pruebas deterministas.
class FakeAdService implements AdService {
  final TemporaryPassRepository _temporaryPassRepository;

  static const Duration interstitialCooldown = Duration(minutes: 10);

  bool isReady = true;
  bool shouldUserCompleteAd = true;
  Duration simulatedLatency = Duration.zero;
  int interstitialShownCount = 0;

  FakeAdService({
    required TemporaryPassRepository temporaryPassRepository,
  }) : _temporaryPassRepository = temporaryPassRepository;

  @override
  Future<void> initialize() async {
    // No-op en fake driver
  }

  @override
  Future<bool> isRewardedAdReady() async {
    return isReady;
  }

  @override
  Future<void> preloadRewardedAd() async {
    isReady = true;
  }

  @override
  Future<AdRewardResult> showRewardedAd(RewardedBenefit benefit) async {
    if (!isReady) {
      return const AdRewardResult.failure(
        AdRewardStatus.adNotAvailable,
        'No hay anuncios bonificados disponibles en este momento.',
      );
    }

    if (simulatedLatency > Duration.zero) {
      await Future<void>.delayed(simulatedLatency);
    }

    if (shouldUserCompleteAd) {
      return const AdRewardResult.success();
    }

    return const AdRewardResult.failure(
      AdRewardStatus.userDismissedEarly,
      'El video no se completó. La recompensa no fue acreditada.',
    );
  }

  @override
  Future<bool> canShowInterstitial({DateTime? referenceTimeUtc}) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    final lastShown = await _temporaryPassRepository.getLastInterstitialShown();
    if (lastShown == null) return true;

    final difference = now.difference(lastShown);
    return difference >= interstitialCooldown;
  }

  @override
  Future<void> preloadInterstitialAd() async {
    // No-op en fake driver
  }

  @override
  Future<void> showInterstitialIfEligible({DateTime? referenceTimeUtc}) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    final eligible = await canShowInterstitial(referenceTimeUtc: now);
    if (!eligible) return;

    if (simulatedLatency > Duration.zero) {
      await Future<void>.delayed(simulatedLatency);
    }

    interstitialShownCount++;
    await _temporaryPassRepository.recordLastInterstitialShown(now);
  }
}
