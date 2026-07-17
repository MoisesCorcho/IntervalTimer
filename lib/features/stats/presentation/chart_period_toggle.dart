import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';

/// Segmented Semana | Mes control (F12 R4). Touch target ≥ 48 dp.
///
/// Height is owned by [ButtonStyle.minimumSize] so the selected segment
/// fill matches the track (no white gap from a taller outer [SizedBox]).
class ChartPeriodToggle extends StatelessWidget {
  const ChartPeriodToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ChartPeriod value;
  final ValueChanged<ChartPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SegmentedButton<ChartPeriod>(
      key: const Key('chart_period_toggle'),
      segments: [
        ButtonSegment(
          value: ChartPeriod.week,
          label: Text(
            UiStrings.progressChartWeek,
            textAlign: TextAlign.center,
            style: textTheme.labelLarge?.copyWith(
              height: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(Icons.view_week_outlined, size: 18),
        ),
        ButtonSegment(
          value: ChartPeriod.month,
          label: Text(
            UiStrings.progressChartMonth,
            textAlign: TextAlign.center,
            style: textTheme.labelLarge?.copyWith(
              height: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(Icons.calendar_view_month_outlined, size: 18),
        ),
      ],
      selected: {value},
      onSelectionChanged: (set) {
        if (set.isEmpty) return;
        onChanged(set.first);
      },
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(0, AppTheme.buttonMinHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        // Keep selected indicator flush with the track edges.
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ).copyWith(
        // Ensure icon + label row is vertically centered in the segment.
        iconSize: const WidgetStatePropertyAll(18),
        textStyle: WidgetStatePropertyAll(
          textTheme.labelLarge?.copyWith(
            height: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
