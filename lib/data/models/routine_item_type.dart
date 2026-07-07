enum RoutineItemType {
  interval;

  String get storageValue => name;

  static RoutineItemType fromStorage(String value) {
    return RoutineItemType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RoutineItemType.interval,
    );
  }
}