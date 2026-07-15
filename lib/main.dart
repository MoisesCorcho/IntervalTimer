import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/app/app.dart';
import 'package:interval_timer/features/lock_screen/application/session_background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // F20: register Android FGS entry-point (autoStart: false).
  // Safe no-op / soft-fail on desktop and when plugins are unavailable.
  try {
    await configureSessionBackgroundService();
  } catch (e, st) {
    debugPrint('configureSessionBackgroundService failed: $e\n$st');
  }
  runApp(const ProviderScope(child: App()));
}