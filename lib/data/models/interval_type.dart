enum IntervalType {
  warmup,
  work,
  rest,
  stretch,
  custom;

  String get storageValue => name;

  static IntervalType fromStorage(String value) {
    return IntervalType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => IntervalType.custom,
    );
  }
}