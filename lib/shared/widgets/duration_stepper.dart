import 'package:flutter/material.dart';
import 'package:interval_timer/shared/widgets/interval_duration_picker.dart';

/// Back-compat alias for [IntervalDurationPicker] (F33 API name).
///
/// Prefer [IntervalDurationPicker] in new call sites.
class DurationStepper extends IntervalDurationPicker {
  const DurationStepper({
    super.key,
    required super.totalSeconds,
    required super.onChanged,
    required super.minSeconds,
    required super.maxSeconds,
    super.minuteStep,
    super.secondStep,
    super.label,
    super.keyPrefix,
  });
}
