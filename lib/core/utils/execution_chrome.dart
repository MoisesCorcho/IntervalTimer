import 'package:flutter/material.dart' hide Interval;
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/contrast_text_color.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';

/// Resolves the full-screen execution background for the current (or preparation)
/// phase.
///
/// Preparation always uses the neutral [AppTheme.prepColor].
/// Brand work and rest phases use the user-configured [workColor] and [restColor]
/// (falling back to [AppTheme.workColor] and [AppTheme.restColor]).
/// Custom intervals keep the user-picked [Interval.colorArgb].
Color executionBackgroundColor({
  required Interval? interval,
  required Color prepFallback,
  bool isPreparation = false,
  Color? workColor,
  Color? restColor,
}) {
  if (isPreparation) return AppTheme.prepColor;
  if (interval == null) return prepFallback;
  return switch (interval.type) {
    IntervalType.work => workColor ?? AppTheme.workColor,
    IntervalType.rest => restColor ?? AppTheme.restColor,
    IntervalType.warmup => AppTheme.warmupColor,
    IntervalType.stretch => AppTheme.stretchColor,
    IntervalType.custom => Color(interval.colorArgb),
  };
}

/// Text / ring / control chrome on the execution canvas.
///
/// Work, rest, custom and preparation dynamically resolve high-contrast
/// foreground color via WCAG [contrastTextColor].
/// Warmup stays black on amber. Stretch stays white.
Color executionChromeColor({
  required Color background,
  required IntervalType? type,
  bool isPreparation = false,
}) {
  if (isPreparation) return contrastTextColor(background);
  return switch (type) {
    IntervalType.warmup => Colors.black,
    IntervalType.stretch => Colors.white,
    IntervalType.work ||
    IntervalType.rest ||
    IntervalType.custom ||
    null =>
      contrastTextColor(background),
  };
}
