import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';

/// Segmented Semana | Mes control (F12 R4). Touch target ≥ 48 dp.
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
    return SizedBox(
      height: AppTheme.buttonMinHeight,
      child: SegmentedButton<ChartPeriod>(
        key: const Key('chart_period_toggle'),
        segments: const [
          ButtonSegment(
            value: ChartPeriod.week,
            label: Text(UiStrings.progressChartWeek),
            icon: Icon(Icons.view_week_outlined, size: 18),
          ),
          ButtonSegment(
            value: ChartPeriod.month,
            label: Text(UiStrings.progressChartMonth),
            icon: Icon(Icons.calendar_view_month_outlined, size: 18),
          ),
        ],
        selected: {value},
        onSelectionChanged: (set) {
          if (set.isEmpty) return;
          onChanged(set.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
    );
  }
}
