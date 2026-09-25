import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';

/// Entidad inmutable que representa un pase de acceso temporal adquirido
/// mediante la visualización de un anuncio bonificado.
class TemporaryPass {
  final String id;
  final RewardedBenefit benefit;
  final DateTime grantedAtUtc;
  final DateTime expiresAtUtc;
  final String source;

  const TemporaryPass({
    required this.id,
    required this.benefit,
    required this.grantedAtUtc,
    required this.expiresAtUtc,
    this.source = 'rewarded_ad',
  });

  /// Indica si el pase ha expirado con respecto a [referenceTimeUtc]
  /// (por defecto `DateTime.now().toUtc()`).
  bool isExpired([DateTime? referenceTimeUtc]) {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    return now.isAfter(expiresAtUtc);
  }

  /// Retorna la duración remanente del pase. Si ya expiró, retorna [Duration.zero].
  Duration remainingTime([DateTime? referenceTimeUtc]) {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    if (now.isAfter(expiresAtUtc)) {
      return Duration.zero;
    }
    return expiresAtUtc.difference(now);
  }
}
