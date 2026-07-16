import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';

/// Bar chart of minutes per day (F12 R4).
class ActivityBarChart extends StatelessWidget {
  const ActivityBarChart({
    super.key,
    required this.series,
    required this.period,
  });

  final List<DayMinutes> series;
  final ChartPeriod period;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxMinutes = series.fold<int>(
      0,
      (m, d) => d.minutes > m ? d.minutes : m,
    );
    final maxY = maxMinutes <= 0 ? 10.0 : (maxMinutes * 1.2).ceilToDouble();

    return Card(
      key: const Key('activity_bar_chart'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingMd,
          AppTheme.spacingMd,
          AppTheme.spacingMd,
          AppTheme.spacingSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 168,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final minutes = rod.toY.round();
                        return BarTooltipItem(
                          '$minutes min',
                          TextStyle(
                            color: scheme.onInverseSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: maxY <= 10 ? 5 : null,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == meta.max) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= series.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _bottomLabel(i),
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: period == ChartPeriod.month ? 9 : 11,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY <= 10 ? 5 : maxY / 2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (var i = 0; i < series.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: series[i].minutes.toDouble(),
                            width: period == ChartPeriod.month ? 6 : 14,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            color: series[i].minutes > 0
                                ? scheme.primary
                                : scheme.outlineVariant.withValues(alpha: 0.35),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              UiStrings.progressChartCaption,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _bottomLabel(int index) {
    if (period == ChartPeriod.week) {
      // series is Mon–Sun; UiStrings.weekdayShort is LUN…DOM
      if (index >= 0 && index < UiStrings.weekdayShort.length) {
        return UiStrings.weekdayShort[index];
      }
      return '';
    }
    // Month: show day number; thin labels every few days if crowded
    final day = index + 1;
    if (series.length > 20 && day % 2 == 0) return '';
    return '$day';
  }
}
