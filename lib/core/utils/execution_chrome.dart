import 'package:flutter/material.dart' hide Interval;
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/contrast_text_color.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';

/// Resolves the full-screen execution background for the current (or next
/// prep) interval.
///
/// Brand phase types always use the design-system swatches so chrome can stay
/// white (F35). Custom intervals keep the user-picked [Interval.colorArgb].
Color executionBackgroundColor({
  required Interval? interval,
  required Color prepFallback,
}) {
  if (interval == null) return prepFallback;
  return switch (interval.type) {
    IntervalType.work => AppTheme.workColor,
    IntervalType.rest => AppTheme.restColor,
    IntervalType.warmup => AppTheme.warmupColor,
    IntervalType.stretch => AppTheme.stretchColor,
    IntervalType.custom => Color(interval.colorArgb),
  };
}

/// Text / ring / control chrome on the execution canvas.
///
/// Work, rest and stretch are always white (F35 product look). Warmup stays
/// black on amber. Custom colors use WCAG [contrastTextColor].
Color executionChromeColor({
  required Color background,
  required IntervalType? type,
}) {
  return switch (type) {
    IntervalType.work ||
    IntervalType.rest ||
    IntervalType.stretch =>
      Colors.white,
    IntervalType.warmup => Colors.black,
    IntervalType.custom || null => contrastTextColor(background),
  };
}
