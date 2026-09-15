import 'dart:async';
import 'package:drift/drift.dart';

/// Global test configuration hook for Flutter Test.
/// Configures Drift test options to suppress duplicate in-memory database warnings
/// generated when multiple test files run in the same test runner process.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
