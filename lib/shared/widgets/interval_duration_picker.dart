import 'package:flutter/material.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/duration_parser.dart';
import 'package:interval_timer/core/utils/stepper_math.dart';
import 'package:interval_timer/shared/widgets/stepper_repeat_button.dart';

/// Vertical minutes/seconds duration picker (premium interval editor UX).
///
/// Controlled by total seconds. Minutes adjust by [minuteStep] * 60;
/// seconds by [secondStep] on the total (not an isolated 0–59 column).
///
/// Composition:
/// `IntervalDurationPicker` → `MinutePicker` + `SecondPicker` + total display.
class IntervalDurationPicker extends StatelessWidget {
  const IntervalDurationPicker({
    super.key,
    required this.totalSeconds,
    required this.onChanged,
    required this.minSeconds,
    required this.maxSeconds,
    this.minuteStep = 1,
    this.secondStep = 5,
    this.label,
    this.keyPrefix = '',
  });

  final int totalSeconds;
  final ValueChanged<int> onChanged;
  final int minSeconds;
  final int maxSeconds;
  final int minuteStep;
  final int secondStep;
  final String? label;
  final String keyPrefix;

  int get _minuteDelta => minuteStep * 60;

  void _apply(int delta) {
    onChanged(
      clampStep(
        value: totalSeconds,
        delta: delta,
        min: minSeconds,
        max: maxSeconds,
      ),
    );
  }

  bool _can(int delta) => canApplyStep(
        value: totalSeconds,
        delta: delta,
        min: minSeconds,
        max: maxSeconds,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatted = formatDurationMmSs(totalSeconds);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final valueLabel = label ?? l10n.duration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMd,
              AppTheme.spacingSm,
              AppTheme.spacingMd,
              AppTheme.spacingMd,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _VerticalUnitPicker(
                        value: minutes,
                        unitLabel: l10n.minutesLabel,
                        decreaseKey: Key(
                          '${keyPrefix}duration_stepper_min_decrement',
                        ),
                        increaseKey: Key(
                          '${keyPrefix}duration_stepper_min_increment',
                        ),
                        decreaseTooltip: l10n.decreaseMinutes,
                        increaseTooltip: l10n.increaseMinutes,
                        canDecrease: _can(-_minuteDelta),
                        canIncrease: _can(_minuteDelta),
                        onDecrease: () => _apply(-_minuteDelta),
                        onIncrease: () => _apply(_minuteDelta),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: _VerticalUnitPicker(
                        value: seconds,
                        unitLabel: l10n.secondsLabel,
                        decreaseKey: Key(
                          '${keyPrefix}duration_stepper_sec_decrement',
                        ),
                        increaseKey: Key(
                          '${keyPrefix}duration_stepper_sec_increment',
                        ),
                        decreaseTooltip: l10n.decreaseSeconds,
                        increaseTooltip: l10n.increaseSeconds,
                        canDecrease: _can(-secondStep),
                        canIncrease: _can(secondStep),
                        onDecrease: () => _apply(-secondStep),
                        onIncrease: () => _apply(secondStep),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                TotalDurationDisplay(
                  key: Key('${keyPrefix}duration_stepper_value'),
                  formatted: formatted,
                  semanticsLabel: '$valueLabel $formatted',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Large animated unit column: chevron up · value · label · chevron down.
class _VerticalUnitPicker extends StatelessWidget {
  const _VerticalUnitPicker({
    required this.value,
    required this.unitLabel,
    required this.decreaseKey,
    required this.increaseKey,
    required this.decreaseTooltip,
    required this.increaseTooltip,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int value;
  final String unitLabel;
  final Key decreaseKey;
  final Key increaseKey;
  final String decreaseTooltip;
  final String increaseTooltip;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final display = value.toString().padLeft(2, '0');

    return Column(
      children: [
        StepperRepeatButton(
          key: increaseKey,
          icon: Icons.keyboard_arrow_up_rounded,
          tooltip: increaseTooltip,
          enabled: canIncrease,
          onStep: onIncrease,
          iconSize: 20,
        ),
        _AnimatedDigit(
          display: display,
          style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 40,
                height: 1.05,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ) ??
              TextStyle(
                fontSize: 40,
                height: 1.05,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
        Text(
          unitLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
        StepperRepeatButton(
          key: decreaseKey,
          icon: Icons.keyboard_arrow_down_rounded,
          tooltip: decreaseTooltip,
          enabled: canDecrease,
          onStep: onDecrease,
          iconSize: 20,
        ),
      ],
    );
  }
}

/// Total duration under the pickers — primary mm:ss, secondary "total".
class TotalDurationDisplay extends StatelessWidget {
  const TotalDurationDisplay({
    super.key,
    required this.formatted,
    required this.semanticsLabel,
  });

  final String formatted;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: semanticsLabel,
      child: Column(
        children: [
          _AnimatedDigit(
            display: formatted,
            style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ) ??
                TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            context.l10n.totalLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDigit extends StatelessWidget {
  const _AnimatedDigit({
    required this.display,
    required this.style,
  });

  final String display;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offset,
            child: child,
          ),
        );
      },
      child: Text(
        display,
        key: ValueKey<String>(display),
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}
