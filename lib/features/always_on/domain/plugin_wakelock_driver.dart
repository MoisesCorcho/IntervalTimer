import 'package:flutter/foundation.dart';
import 'package:interval_timer/features/always_on/domain/wakelock_driver.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Wraps [WakelockPlus]; all failures become no-ops (R11).
class PluginWakelockDriver implements WakelockDriver {
  @override
  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (e, st) {
      debugPrint('PluginWakelockDriver.enable failed: $e\n$st');
    }
  }

  @override
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (e, st) {
      debugPrint('PluginWakelockDriver.disable failed: $e\n$st');
    }
  }

  @override
  Future<bool> get isEnabled async {
    try {
      return await WakelockPlus.enabled;
    } catch (e, st) {
      debugPrint('PluginWakelockDriver.isEnabled failed: $e\n$st');
      return false;
    }
  }
}
