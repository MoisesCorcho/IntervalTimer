import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:interval_timer/features/monetization/data/temporary_pass_repository.dart';
import 'package:interval_timer/features/monetization/domain/ad_reward_result.dart';
import 'package:interval_timer/features/monetization/domain/ad_service.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';

/// Implementación concreta de producción de [AdService] respaldada por Google Mobile Ads (AdMob).
class AdMobAdService implements AdService {
  final TemporaryPassRepository _temporaryPassRepository;

  static const Duration interstitialCooldown = Duration(minutes: 10);

  // Official Google AdMob Test Ad Unit IDs
  static const String _androidTestRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestRewardedId =
      'ca-app-pub-3940256099942544/1712485313';

  static const String _androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  AdMobAdService({
    required TemporaryPassRepository temporaryPassRepository,
  }) : _temporaryPassRepository = temporaryPassRepository;

  String get rewardedAdUnitId {
    const customAndroid = String.fromEnvironment('ADMOB_ANDROID_REWARDED_ID');
    const customIos = String.fromEnvironment('ADMOB_IOS_REWARDED_ID');

    if (!kReleaseMode) {
      return Platform.isAndroid ? _androidTestRewardedId : _iosTestRewardedId;
    }

    if (Platform.isAndroid) {
      return customAndroid.isNotEmpty ? customAndroid : _androidTestRewardedId;
    } else {
      return customIos.isNotEmpty ? customIos : _iosTestRewardedId;
    }
  }

  String get interstitialAdUnitId {
    const customAndroid = String.fromEnvironment('ADMOB_ANDROID_INTERSTITIAL_ID');
    const customIos = String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID');

    if (!kReleaseMode) {
      return Platform.isAndroid
          ? _androidTestInterstitialId
          : _iosTestInterstitialId;
    }

    if (Platform.isAndroid) {
      return customAndroid.isNotEmpty
          ? customAndroid
          : _androidTestInterstitialId;
    } else {
      return customIos.isNotEmpty ? customIos : _iosTestInterstitialId;
    }
  }

  Completer<void>? _rewardedPreloadCompleter;
  Completer<void>? _interstitialPreloadCompleter;

  @override
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      preloadRewardedAd();
      preloadInterstitialAd();
    } catch (e) {
      debugPrint('[AdMobAdService] Error initializing MobileAds: $e');
    }
  }

  @override
  Future<bool> isRewardedAdReady() async {
    return _rewardedAd != null;
  }

  @override
  Future<void> preloadRewardedAd() async {
    if (_rewardedAd != null) return;
    if (_rewardedPreloadCompleter != null) {
      return _rewardedPreloadCompleter!.future;
    }

    final completer = Completer<void>();
    _rewardedPreloadCompleter = completer;

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _rewardedPreloadCompleter = null;
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (error) {
            debugPrint('[AdMobAdService] RewardedAd failed to load: $error');
            _rewardedAd = null;
            _rewardedPreloadCompleter = null;
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
    } catch (e) {
      _rewardedPreloadCompleter = null;
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  @override
  Future<AdRewardResult> showRewardedAd(RewardedBenefit benefit) async {
    if (_rewardedAd == null) {
      await preloadRewardedAd();
      if (_rewardedAd == null) {
        return const AdRewardResult.failure(
          AdRewardStatus.adNotAvailable,
          'No hay anuncios bonificados disponibles. Comprueba tu conexión a internet.',
        );
      }
    }

    final completer = Completer<AdRewardResult>();
    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        preloadRewardedAd(); // Precarga el siguiente

        if (!completer.isCompleted) {
          if (rewardEarned) {
            completer.complete(const AdRewardResult.success());
          } else {
            completer.complete(
              const AdRewardResult.failure(
                AdRewardStatus.userDismissedEarly,
                'El video fue cerrado antes de finalizar. Recompensa no otorgada.',
              ),
            );
          }
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMobAdService] Failed to show RewardedAd: $error');
        ad.dispose();
        _rewardedAd = null;
        preloadRewardedAd();

        if (!completer.isCompleted) {
          completer.complete(
            AdRewardResult.failure(
              AdRewardStatus.adNotAvailable,
              'Fallo al mostrar el anuncio: ${error.message}',
            ),
          );
        }
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
        },
      );

      return await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          return const AdRewardResult.failure(
            AdRewardStatus.adNotAvailable,
            'Tiempo de espera del anuncio bonificado excedido.',
          );
        },
      );
    } catch (e) {
      return AdRewardResult.failure(
        AdRewardStatus.adNotAvailable,
        'Error inesperado al mostrar video bonificado: $e',
      );
    }
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
    if (_interstitialAd != null) return;
    if (_interstitialPreloadCompleter != null) {
      return _interstitialPreloadCompleter!.future;
    }

    final completer = Completer<void>();
    _interstitialPreloadCompleter = completer;

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialPreloadCompleter = null;
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (error) {
            debugPrint('[AdMobAdService] InterstitialAd failed to load: $error');
            _interstitialAd = null;
            _interstitialPreloadCompleter = null;
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
    } catch (e) {
      _interstitialPreloadCompleter = null;
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  @override
  Future<void> showInterstitialIfEligible({DateTime? referenceTimeUtc}) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    final eligible = await canShowInterstitial(referenceTimeUtc: now);
    if (!eligible) return;

    if (_interstitialAd == null) {
      await preloadInterstitialAd();
      if (_interstitialAd == null) return;
    }

    final completer = Completer<void>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitialAd();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMobAdService] Failed to show Interstitial: $error');
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitialAd();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await _temporaryPassRepository.recordLastInterstitialShown(now);
    try {
      await _interstitialAd!.show();
      await completer.future.timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('[AdMobAdService] Interstitial show timed out; continuing navigation.');
        },
      );
    } catch (e) {
      debugPrint('[AdMobAdService] Error showing interstitial: $e');
    }
  }
}
