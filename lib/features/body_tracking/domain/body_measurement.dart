import 'package:interval_timer/core/utils/local_date_format.dart';

/// Domain entity for one daily body measurement (F15).
///
/// Canonical units: [weightKg] in kg, optional measures in cm.
class BodyMeasurement {
  const BodyMeasurement({
    required this.id,
    required this.localDate,
    required this.weightKg,
    this.waistCm,
    this.armCm,
    this.legCm,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  /// `yyyy-MM-dd` local calendar day (unique per day).
  final String localDate;
  final double weightKg;
  final double? waistCm;
  final double? armCm;
  final double? legCm;
  final DateTime createdAt;
  final DateTime updatedAt;

  BodyMeasurement copyWith({
    String? id,
    String? localDate,
    double? weightKg,
    double? waistCm,
    double? armCm,
    double? legCm,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearWaist = false,
    bool clearArm = false,
    bool clearLeg = false,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      localDate: localDate ?? this.localDate,
      weightKg: weightKg ?? this.weightKg,
      waistCm: clearWaist ? null : (waistCm ?? this.waistCm),
      armCm: clearArm ? null : (armCm ?? this.armCm),
      legCm: clearLeg ? null : (legCm ?? this.legCm),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is BodyMeasurement &&
            other.id == id &&
            other.localDate == localDate &&
            other.weightKg == weightKg &&
            other.waistCm == waistCm &&
            other.armCm == armCm &&
            other.legCm == legCm &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt);
  }

  @override
  int get hashCode => Object.hash(
        id,
        localDate,
        weightKg,
        waistCm,
        armCm,
        legCm,
        createdAt,
        updatedAt,
      );
}

/// Pure validation for body measurements (F15 R10–R11). Testable without Flutter.
abstract final class BodyMeasurementValidation {
  static const minWeightKg = 20.0;
  static const maxWeightKg = 300.0;
  static const maxMeasureCm = 300.0;

  /// Returns an error code key, or null if valid.
  ///
  /// Codes: `weight_required`, `weight_invalid`, `weight_range`.
  static String? validateWeightKg(double? weightKg) {
    if (weightKg == null) return 'weight_required';
    if (!weightKg.isFinite) return 'weight_invalid';
    if (weightKg <= 0) return 'weight_invalid';
    if (weightKg < minWeightKg || weightKg > maxWeightKg) {
      return 'weight_range';
    }
    return null;
  }

  /// Optional measure: null OK; if present must be finite, > 0 and ≤ 300.
  ///
  /// Codes: `measure_invalid`, `measure_range`.
  static String? validateMeasureCm(double? cm) {
    if (cm == null) return null;
    if (!cm.isFinite || cm <= 0) return 'measure_invalid';
    if (cm > maxMeasureCm) return 'measure_range';
    return null;
  }

  /// [localDate] must be `yyyy-MM-dd` and not after [today] (local).
  ///
  /// Codes: `date_invalid`, `date_future`.
  static String? validateLocalDate(
    String localDate, {
    DateTime? now,
  }) {
    final DateTime parsed;
    try {
      parsed = LocalDateFormat.parse(localDate);
    } on FormatException {
      return 'date_invalid';
    } catch (_) {
      return 'date_invalid';
    }

    final today = (now ?? DateTime.now()).toLocal();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(parsed.year, parsed.month, parsed.day);
    if (dateOnly.isAfter(todayDate)) return 'date_future';
    return null;
  }

  /// Full entity validation; returns first error code or null.
  static String? validate(BodyMeasurement m, {DateTime? now}) {
    return validateWeightKg(m.weightKg) ??
        validateMeasureCm(m.waistCm) ??
        validateMeasureCm(m.armCm) ??
        validateMeasureCm(m.legCm) ??
        validateLocalDate(m.localDate, now: now);
  }
}
