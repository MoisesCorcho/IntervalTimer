enum SessionLogStatus {
  completed,
  aborted;

  String get storageValue => name;

  static SessionLogStatus fromStorage(String value) {
    return SessionLogStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SessionLogStatus.completed,
    );
  }
}
