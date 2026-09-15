import 'package:interval_timer/features/monetization/domain/ad_reward_result.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';

/// Contrato abstracto del puerto de publicidad (Ports & Adapters).
/// Desacopla por completo la UI y el dominio del SDK nativo de Google Mobile Ads.
abstract interface class AdService {
  /// Inicializa los drivers o servicios publicitarios.
  Future<void> initialize();

  /// Consulta si hay un video bonificado cargado y listo para ser mostrado.
  Future<bool> isRewardedAdReady();

  /// Precarga un video bonificado en segundo plano.
  Future<void> preloadRewardedAd();

  /// Muestra el video bonificado para el beneficio solicitado.
  /// Retorna [AdRewardResult.success] únicamente si el usuario vio el video completo.
  Future<AdRewardResult> showRewardedAd(RewardedBenefit benefit);

  /// Consulta si corresponde mostrar un intersticial post-entrenamiento
  /// respetando el cooldown técnico de 10 minutos.
  Future<bool> canShowInterstitial();

  /// Precarga un anuncio intersticial en segundo plano.
  Future<void> preloadInterstitialAd();

  /// Muestra el anuncio intersticial si es elegible.
  Future<void> showInterstitialIfEligible();
}
