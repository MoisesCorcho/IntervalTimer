/// Abstraction over screen wakelock (F19). Testable without platform plugins.
abstract class WakelockDriver {
  Future<void> enable();

  Future<void> disable();

  Future<bool> get isEnabled;
}
