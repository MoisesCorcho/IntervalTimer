import 'dart:convert';
import 'package:interval_timer/data/repositories/preferences_repository.dart';

/// Gestiona la política de límite diario (Daily Cap) y el enfriamiento (Cooldown)
/// entre visualizaciones de videos bonificados.
class DailyRewardedAdTracker {
  final PreferencesRepository _prefs;

  static const String historyKey = 'monetization_rewarded_ad_timestamps';
  static const int maxDailyAds = 2;
  static const Duration adCooldown = Duration(minutes: 15);
  static const Duration dailyWindow = Duration(hours: 24);

  DailyRewardedAdTracker(this._prefs);

  /// Registra la visualización exitosa de un anuncio bonificado.
  Future<void> recordAdWatched(DateTime utcTimestamp) async {
    final history = await _loadTimestamps();
    history.add(utcTimestamp);

    // Conservamos solo los timestamps de las últimas 48 horas para no inflar preferencias
    final cutoff = utcTimestamp.subtract(const Duration(hours: 48));
    final pruned = history.where((t) => t.isAfter(cutoff)).toList();

    final jsonList = pruned.map((t) => t.toIso8601String()).toList();
    await _prefs.setString(historyKey, jsonEncode(jsonList));
  }

  /// Retorna la cantidad de videos bonificados visualizados en la ventana deslizante de las últimas 24 horas.
  Future<int> getDailyCount({DateTime? referenceTimeUtc}) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    final windowStart = now.subtract(dailyWindow);
    final history = await _loadTimestamps();

    // Si el usuario manipuló el reloj hacia el pasado, los timestamps posteriores a 'now'
    // siguen computando en el cupo para impedir el bypass del límite diario.
    return history.where((t) => t.isAfter(windowStart)).length;
  }

  /// Indica si existe un periodo de enfriamiento activo (15 minutos desde el último video).
  Future<bool> isCooldownActive({DateTime? referenceTimeUtc}) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    final last = await _getLastAdTimestamp();
    if (last == null) return false;

    // Si el reloj fue manipulado hacia atrás, se bloquea por enfriamiento
    if (now.isBefore(last)) return true;

    final diff = now.difference(last);
    return diff < adCooldown;
  }

  /// Retorna el tiempo remanente de enfriamiento si está activo.
  Future<Duration> getRemainingCooldown({DateTime? referenceTimeUtc}) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    final last = await _getLastAdTimestamp();
    if (last == null) return Duration.zero;

    if (now.isBefore(last)) return adCooldown;

    final elapsed = now.difference(last);
    if (elapsed >= adCooldown) return Duration.zero;
    return adCooldown - elapsed;
  }

  /// Evalúa si el usuario es elegible para ver un video bonificado en este instante.
  Future<bool> canWatchAd({DateTime? referenceTimeUtc}) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();

    final last = await _getLastAdTimestamp();
    if (last != null && now.isBefore(last)) {
      return false; // Detección de manipulación de reloj
    }

    final count = await getDailyCount(referenceTimeUtc: now);
    if (count >= maxDailyAds) return false;

    final cooldownActive = await isCooldownActive(referenceTimeUtc: now);
    if (cooldownActive) return false;

    return true;
  }

  Future<DateTime?> _getLastAdTimestamp() async {
    final history = await _loadTimestamps();
    if (history.isEmpty) return null;
    history.sort((a, b) => b.compareTo(a));
    return history.first;
  }

  Future<List<DateTime>> _loadTimestamps() async {
    final raw = await _prefs.getString(historyKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => DateTime.parse(item as String).toUtc())
          .toList();
    } catch (_) {
      return [];
    }
  }
}
