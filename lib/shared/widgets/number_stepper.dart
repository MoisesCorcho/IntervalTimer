import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/stepper_math.dart';
import 'package:interval_timer/shared/widgets/stepper_repeat_button.dart';

/// Controlled integer stepper: horizontal [−] value [+] (sets and small ints).
///
/// Long-press auto-repeats for faster adjustment of larger ranges.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.step = 1,
    this.label,
    this.semanticsLabel,
    this.keyPrefix = '',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final String? label;
  final String? semanticsLabel;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canDecrement = canApplyStep(
      value: value,
      delta: -step,
      min: min,
      max: max,
    );
    final canIncrement = canApplyStep(
      value: value,
      delta: step,
      min: min,
      max: max,
    );
    final valueLabel = semanticsLabel ?? label ?? 'valor';

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
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingSm,
            ),
            child: Row(
              children: [
                StepperRepeatButton(
                  key: Key('${keyPrefix}number_stepper_decrement'),
                  icon: Icons.remove_rounded,
                  tooltip: 'Disminuir $valueLabel',
                  enabled: canDecrement,
                  onStep: () => onChanged(
                    clampStep(
                      value: value,
                      delta: -step,
                      min: min,
                      max: max,
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label: '$valueLabel $value',
                    child: KeyedSubtree(
                      key: Key('${keyPrefix}number_stepper_value'),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.92, end: 1)
                                  .animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          key: ValueKey<int>(value),
                          '$value',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                StepperRepeatButton(
                  key: Key('${keyPrefix}number_stepper_increment'),
                  icon: Icons.add_rounded,
                  tooltip: 'Aumentar $valueLabel',
                  enabled: canIncrement,
                  onStep: () => onChanged(
                    clampStep(
                      value: value,
                      delta: step,
                      min: min,
                      max: max,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
