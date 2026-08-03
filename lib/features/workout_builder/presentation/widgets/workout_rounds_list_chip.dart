import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';

/// Compact rounds badge for the workouts list (F32).
///
/// Colors are read from the current [ColorScheme] on every build so light/dark
/// switches update immediately (M3 default Chip surfaces can lag after theme
/// changes when only labelStyle is customized).
class WorkoutRoundsListChip extends StatelessWidget {
  const WorkoutRoundsListChip({
    super.key,
    required this.workoutId,
    required this.rounds,
  });

  final String workoutId;
  final int rounds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = UiStrings.workoutRoundsListLabel
        .replaceAll('{count}', '$rounds');

    // Explicit scheme colors + no surface tint: avoids sticky M3 chip surfaces
    // when ThemeMode flips while this ListView item stays mounted.
    return Chip(
      key: Key('workout_rounds_chip_$workoutId'),
      avatar: Icon(
        Icons.loop_rounded,
        size: 16,
        color: scheme.onSecondaryContainer,
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: scheme.secondaryContainer,
      surfaceTintColor: Colors.transparent,
      side: BorderSide(color: scheme.outlineVariant),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: scheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
