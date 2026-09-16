import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/features/monetization/application/daily_rewarded_ad_tracker.dart';
import 'package:interval_timer/features/monetization/data/temporary_pass_repository.dart';
import 'package:interval_timer/features/monetization/domain/ad_reward_result.dart';
import 'package:interval_timer/features/monetization/domain/ad_service.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/monetization/domain/temporary_pass.dart';
import 'package:interval_timer/features/monetization/infrastructure/admob_ad_service.dart';
import 'package:interval_timer/features/monetization/infrastructure/fake_ad_service.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';

/// Proveedor del repositorio de pases temporales en Drift SQLite.
final temporaryPassRepositoryProvider = Provider<TemporaryPassRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final prefs = ref.watch(preferencesRepositoryProvider);
  return TemporaryPassRepository(db, prefs);
});

/// Proveedor del tracker de límite diario y cooldown de anuncios.
final dailyRewardedAdTrackerProvider = Provider<DailyRewardedAdTracker>((ref) {
  final prefs = ref.watch(preferencesRepositoryProvider);
  return DailyRewardedAdTracker(prefs);
});

/// Proveedor del servicio de anuncios (Ports & Adapters).
/// Inyecta [FakeAdService] por defecto para desarrollo, CI y tests deterministas.
/// Inyecta [AdMobAdService] en entornos de producción (release mode) o con FORCE_ADMOB=true.
final adServiceProvider = Provider<AdService>((ref) {
  final passRepo = ref.watch(temporaryPassRepositoryProvider);

  const forceAdMob = bool.fromEnvironment('FORCE_ADMOB', defaultValue: false);
  final shouldUseAdMob = (kReleaseMode || forceAdMob);

  if (shouldUseAdMob) {
    return AdMobAdService(temporaryPassRepository: passRepo);
  }

  return FakeAdService(temporaryPassRepository: passRepo);
});

/// Stream reactivo de pases temporales activos vigentes.
final activeTemporaryPassesProvider = StreamProvider<List<TemporaryPass>>((ref) {
  final passRepo = ref.watch(temporaryPassRepositoryProvider);
  return passRepo.watchActivePasses();
});

/// Consulta reactiva de elegibilidad para ver un anuncio bonificado en el instante actual.
final canWatchRewardedAdProvider = FutureProvider<bool>((ref) async {
  final tracker = ref.watch(dailyRewardedAdTrackerProvider);
  return tracker.canWatchAd();
});

/// Cantidad de anuncios bonificados visualizados en las últimas 24h.
final dailyRewardedAdCountProvider = FutureProvider<int>((ref) async {
  final tracker = ref.watch(dailyRewardedAdTrackerProvider);
  return tracker.getDailyCount();
});

/// Evalúa de forma unificada si [benefit] está desbloqueado para el usuario:
/// 1. Precedencia Suprema: Si el usuario es Pro (`isProUserProvider == true`), retorna true.
/// 2. Pases Temporales: Retorna true si existe un [TemporaryPass] activo y no expirado para ese beneficio.
final isBenefitUnlockedProvider = Provider.family<bool, RewardedBenefit>((ref, benefit) {
  final isPro = ref.watch(isProUserProvider).valueOrNull ?? false;
  if (isPro) return true;

  final activePasses = ref.watch(activeTemporaryPassesProvider).valueOrNull ?? [];
  return activePasses.any((pass) => pass.benefit == benefit && !pass.isExpired());
});

/// Estado del controlador de monetización.
class MonetizationState {
  final bool isLoading;
  final String? errorMessage;
  final TemporaryPass? lastGrantedPass;

  const MonetizationState({
    this.isLoading = false,
    this.errorMessage,
    this.lastGrantedPass,
  });

  MonetizationState copyWith({
    bool? isLoading,
    String? errorMessage,
    TemporaryPass? lastGrantedPass,
  }) {
    return MonetizationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastGrantedPass: lastGrantedPass ?? this.lastGrantedPass,
    );
  }
}

/// Orquestador de aplicación para solicitar la visualización de videos bonificados y conceder pases.
class MonetizationController extends StateNotifier<MonetizationState> {
  final AdService _adService;
  final TemporaryPassRepository _passRepo;
  final DailyRewardedAdTracker _tracker;
  final Ref _ref;

  MonetizationController({
    required AdService adService,
    required TemporaryPassRepository passRepo,
    required DailyRewardedAdTracker tracker,
    required Ref ref,
  })  : _adService = adService,
        _passRepo = passRepo,
        _tracker = tracker,
        _ref = ref,
        super(const MonetizationState());

  /// Solicita reproducir un video bonificado para desbloquear [benefit].
  /// Si se completa exitosamente, concede el pase temporal en SQLite y refresca el tracker.
  Future<bool> requestRewardedUnlock(RewardedBenefit benefit) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final canWatch = await _tracker.canWatchAd();
    if (!canWatch) {
      final isCooldown = await _tracker.isCooldownActive();
      final msg = isCooldown
          ? 'Por favor espera unos minutos antes de ver otro anuncio.'
          : 'Límite diario de 2 videos alcanzado. Puedes volver a ver videos mañana o pasar a Pro.';
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    }

    final result = await _adService.showRewardedAd(benefit);

    if (result.isSuccess) {
      final pass = await _passRepo.grantPass(
        benefit: benefit,
        duration: benefit.defaultDuration,
      );

      await _tracker.recordAdWatched(DateTime.now().toUtc());

      // Invalidamos providers para actualización reactiva inmediata en la UI
      _ref.invalidate(canWatchRewardedAdProvider);
      _ref.invalidate(dailyRewardedAdCountProvider);

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        lastGrantedPass: pass,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage ?? 'No se pudo completar el anuncio.',
      );
      return false;
    }
  }
}

final monetizationControllerProvider =
    StateNotifierProvider<MonetizationController, MonetizationState>((ref) {
  final adService = ref.watch(adServiceProvider);
  final passRepo = ref.watch(temporaryPassRepositoryProvider);
  final tracker = ref.watch(dailyRewardedAdTrackerProvider);

  return MonetizationController(
    adService: adService,
    passRepo: passRepo,
    tracker: tracker,
    ref: ref,
  );
});
