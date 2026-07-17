import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/workout_builder/domain/workout_validators.dart';
import 'package:interval_timer/shared/widgets/number_stepper.dart';

/// Premium editor card for global workout rounds (F32 R21).
///
/// Visual language: soft primary gradient, icon bubble, hierarchy + stepper —
/// aligned with F12 [StatMetricCard] and F33 [NumberStepper].
class WorkoutRoundsCard extends StatelessWidget {
  const WorkoutRoundsCard({
    super.key,
    required this.rounds,
    required this.onChanged,
    this.enabled = true,
  });

  final int rounds;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = scheme.primary;

    final tintStrong = Color.alphaBlend(
      accent.withValues(alpha: 0.14),
      scheme.surface,
    );
    final tintSoft = Color.alphaBlend(
      accent.withValues(alpha: 0.05),
      scheme.surface,
    );
    final bubbleFill = accent.withValues(alpha: 0.18);
    final borderColor = accent.withValues(alpha: 0.22);

    final clamped = WorkoutValidators.clampRounds(rounds);
    final semanticsValue =
        '${UiStrings.workoutRoundsTitle}, $clamped';

    return Semantics(
      label: semanticsValue,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tintStrong, tintSoft],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: bubbleFill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.loop_rounded,
                      color: accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          UiStrings.workoutRoundsTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          UiStrings.workoutRoundsHelper,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (clamped > 1) ...[
                const SizedBox(height: AppTheme.spacingSm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(
                      Icons.repeat_rounded,
                      size: 16,
                      color: accent,
                    ),
                    label: Text(
                      UiStrings.workoutRoundsBlockChip
                          .replaceAll('{count}', '$clamped'),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(color: borderColor),
                    backgroundColor: accent.withValues(alpha: 0.10),
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingMd),
              Opacity(
                opacity: enabled ? 1 : 0.5,
                child: IgnorePointer(
                  ignoring: !enabled,
                  child: NumberStepper(
                    keyPrefix: 'workout_rounds_',
                    value: clamped,
                    min: WorkoutValidators.minRounds,
                    max: WorkoutValidators.maxRounds,
                    label: UiStrings.workoutRoundsShort,
                    semanticsLabel: UiStrings.workoutRoundsShort,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
