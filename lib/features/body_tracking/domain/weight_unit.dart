/// Presentation-only body weight unit (F15). Canonical storage is always kg.
enum BodyWeightUnit {
  kg,
  lb;

  static const kgToLbFactor = 2.2046226218;

  String get storageValue => name;

  static BodyWeightUnit fromStorage(String? raw) {
    return switch (raw) {
      'lb' => BodyWeightUnit.lb,
      _ => BodyWeightUnit.kg,
    };
  }

  /// Converts a value stored/entered in [from] into kilograms.
  static double toKg(double value, BodyWeightUnit from) {
    return switch (from) {
      BodyWeightUnit.kg => value,
      BodyWeightUnit.lb => value / kgToLbFactor,
    };
  }

  /// Converts kilograms into the display unit.
  static double fromKg(double weightKg, BodyWeightUnit to) {
    return switch (to) {
      BodyWeightUnit.kg => weightKg,
      BodyWeightUnit.lb => weightKg * kgToLbFactor,
    };
  }

  /// Round-trip friendly display with one decimal.
  static String formatDisplay(double weightKg, BodyWeightUnit unit) {
    final v = fromKg(weightKg, unit);
    return v.toStringAsFixed(1);
  }
}
