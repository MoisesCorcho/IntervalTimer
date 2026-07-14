import 'package:flutter/foundation.dart';
import 'package:interval_timer/features/vibration/domain/vibration_driver.dart';
import 'package:vibration/vibration.dart';

/// Wraps package:vibration; all failures become no-ops (R7).
class PluginVibrationDriver implements VibrationDriver {
  @override
  Future<bool> hasVibrator() async {
    try {
      return await Vibration.hasVibrator();
    } catch (e, st) {
      debugPrint('PluginVibrationDriver.hasVibrator failed: $e\n$st');
      return false;
    }
  }

  @override
  Future<void> vibrate({int? durationMs, List<int>? pattern}) async {
    try {
      final has = await Vibration.hasVibrator();
      if (!has) return;

      if (pattern != null && pattern.isNotEmpty) {
        final custom = await Vibration.hasCustomVibrationsSupport();
        if (custom) {
          await Vibration.vibrate(pattern: pattern);
          return;
        }
        // Degrade pattern B to a short single pulse when custom is unsupported.
        await Vibration.vibrate(duration: durationMs ?? 25);
        return;
      }

      await Vibration.vibrate(duration: durationMs ?? 60);
    } catch (e, st) {
      debugPrint('PluginVibrationDriver.vibrate failed: $e\n$st');
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await Vibration.cancel();
    } catch (e, st) {
      debugPrint('PluginVibrationDriver.cancel failed: $e\n$st');
    }
  }
}
