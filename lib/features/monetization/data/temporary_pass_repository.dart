import 'package:drift/drift.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/monetization/domain/rewarded_benefit.dart';
import 'package:interval_timer/features/monetization/domain/temporary_pass.dart';

/// Repositorio atómico para la persistencia y consulta de pases temporales en Drift SQLite.
class TemporaryPassRepository {
  final AppDatabase _db;
  final PreferencesRepository _prefs;

  static const String maxVerifiedUtcKey = 'monetization_max_verified_utc';
  static const String lastInterstitialShownKey = 'monetization_last_interstitial_utc';

  TemporaryPassRepository(this._db, this._prefs);

  /// Concede un pase temporal para [benefit] con la [duration] especificada.
  /// Si ya existía un pase para este beneficio, se reemplaza con la nueva expiración.
  Future<TemporaryPass> grantPass({
    required RewardedBenefit benefit,
    required Duration duration,
    DateTime? referenceTimeUtc,
    String source = 'rewarded_ad',
  }) async {
    final grantedAt = referenceTimeUtc ?? DateTime.now().toUtc();
    final expiresAt = grantedAt.add(duration);
    final passId = 'pass_${benefit.name}';

    await _db.into(_db.temporaryPasses).insertOnConflictUpdate(
          TemporaryPassesCompanion(
            id: Value(passId),
            benefitType: Value(benefit.name),
            grantedAtUtc: Value(grantedAt),
            expiresAtUtc: Value(expiresAt),
            source: Value(source),
          ),
        );

    await recordVerifiedTimestamp(grantedAt);

    return TemporaryPass(
      id: passId,
      benefit: benefit,
      grantedAtUtc: grantedAt,
      expiresAtUtc: expiresAt,
      source: source,
    );
  }

  /// Consulta si existe un pase activo y vigente para [benefit].
  Future<bool> hasActivePass(
    RewardedBenefit benefit, {
    DateTime? referenceTimeUtc,
  }) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    if (await isClockTampered(now)) {
      return false;
    }

    final row = await (_db.select(_db.temporaryPasses)
          ..where(
            (t) =>
                t.benefitType.equals(benefit.name) &
                t.expiresAtUtc.isBiggerThanValue(now),
          ))
        .getSingleOrNull();

    return row != null;
  }

  /// Retorna la lista de todos los pases vigentes no expirados.
  Future<List<TemporaryPass>> getActivePasses({
    DateTime? referenceTimeUtc,
  }) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    if (await isClockTampered(now)) {
      return [];
    }

    final rows = await (_db.select(_db.temporaryPasses)
          ..where((t) => t.expiresAtUtc.isBiggerThanValue(now)))
        .get();

    return rows.map(_mapRowToEntity).toList();
  }

  /// Emite reactivamente la lista de pases temporales activos.
  Stream<List<TemporaryPass>> watchActivePasses({
    DateTime? referenceTimeUtc,
  }) {
    return _db.select(_db.temporaryPasses).watch().asyncMap((rows) async {
      final now = referenceTimeUtc ?? DateTime.now().toUtc();
      if (await isClockTampered(now)) {
        return <TemporaryPass>[];
      }
      return rows
          .where((row) => row.expiresAtUtc.toUtc().isAfter(now))
          .map(_mapRowToEntity)
          .toList();
    });
  }

  /// Elimina de la base de datos todos los pases cuya fecha de expiración haya pasado.
  Future<int> purgeExpiredPasses({DateTime? referenceTimeUtc}) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    return (_db.delete(_db.temporaryPasses)
          ..where((t) => t.expiresAtUtc.isSmallerOrEqualValue(now)))
        .go();
  }

  /// Registra la marca de agua del mayor timestamp UTC conocido.
  Future<void> recordVerifiedTimestamp(DateTime utc) async {
    final maxUtcString = await _prefs.getString(maxVerifiedUtcKey);
    if (maxUtcString != null) {
      final savedMax = DateTime.tryParse(maxUtcString);
      if (savedMax != null && savedMax.isAfter(utc)) {
        return; // No retrocede la marca de agua
      }
    }
    await _prefs.setString(maxVerifiedUtcKey, utc.toIso8601String());

    await _db.into(_db.adMetadata).insertOnConflictUpdate(
          AdMetadataCompanion(
            key: const Value(maxVerifiedUtcKey),
            value: Value(utc.toIso8601String()),
            updatedAtUtc: Value(utc),
          ),
        );
  }

  /// Detecta si el reloj del dispositivo se ha manipulado hacia el pasado.
  Future<bool> isClockTampered([DateTime? referenceTimeUtc]) async {
    final now = referenceTimeUtc ?? DateTime.now().toUtc();
    final maxUtcString = await _prefs.getString(maxVerifiedUtcKey);
    if (maxUtcString == null) return false;

    final savedMax = DateTime.tryParse(maxUtcString);
    if (savedMax == null) return false;

    return now.isBefore(savedMax);
  }

  /// Registra el timestamp del último anuncio intersticial mostrado.
  Future<void> recordLastInterstitialShown(DateTime utc) async {
    await _prefs.setString(lastInterstitialShownKey, utc.toIso8601String());
    await _db.into(_db.adMetadata).insertOnConflictUpdate(
          AdMetadataCompanion(
            key: const Value(lastInterstitialShownKey),
            value: Value(utc.toIso8601String()),
            updatedAtUtc: Value(utc),
          ),
        );
    await recordVerifiedTimestamp(utc);
  }

  /// Retorna el timestamp del último anuncio intersticial mostrado.
  Future<DateTime?> getLastInterstitialShown() async {
    final str = await _prefs.getString(lastInterstitialShownKey);
    if (str == null) return null;
    return DateTime.tryParse(str)?.toUtc();
  }

  TemporaryPass _mapRowToEntity(TemporaryPassRow row) {
    final benefit = RewardedBenefit.values.firstWhere(
      (b) => b.name == row.benefitType,
      orElse: () => RewardedBenefit.adFreePass,
    );

    return TemporaryPass(
      id: row.id,
      benefit: benefit,
      grantedAtUtc: row.grantedAtUtc.toUtc(),
      expiresAtUtc: row.expiresAtUtc.toUtc(),
      source: row.source,
    );
  }
}
