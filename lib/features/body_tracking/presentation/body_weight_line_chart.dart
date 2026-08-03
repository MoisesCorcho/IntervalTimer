import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/body_tracking/domain/body_measurement.dart';
import 'package:interval_timer/features/body_tracking/domain/weight_unit.dart';

/// Line chart of weight vs time (F15 R5). Values shown in [unit].
class BodyWeightLineChart extends StatelessWidget {
  const BodyWeightLineChart({
    super.key,
    required this.measurements,
    required this.unit,
  });

  final List<BodyMeasurement> measurements;
  final BodyWeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (measurements.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < measurements.length; i++) {
      final display =
          BodyWeightUnit.fromKg(measurements[i].weightKg, unit);
      spots.add(FlSpot(i.toDouble(), display));
    }

    final values = spots.map((s) => s.y).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final pad = ((maxVal - minVal).abs() < 0.1) ? 2.0 : (maxVal - minVal) * 0.15;
    final minY = (minVal - pad).clamp(0.0, double.infinity);
    final maxY = maxVal + pad;

    return Card(
      key: const Key('body_weight_line_chart'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingMd,
          AppTheme.spacingMd,
          AppTheme.spacingMd,
          AppTheme.spacingSm,
        ),
        child: SizedBox(
          height: 176,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              minX: 0,
              maxX: (measurements.length - 1).toDouble().clamp(0, double.infinity),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touched) {
                    return touched.map((t) {
                      final i = t.x.round();
                      if (i < 0 || i >= measurements.length) {
                        return null;
                      }
                      final m = measurements[i];
                      final v = BodyWeightUnit.formatDisplay(m.weightKg, unit);
                      final label = unit == BodyWeightUnit.kg
                          ? '$v kg'
                          : '$v lb';
                      return LineTooltipItem(
                        '${m.localDate}\n$label',
                        TextStyle(
                          color: scheme.onInverseSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 3,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
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
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) {
                        return Text(
                          value.toStringAsFixed(0),
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
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.round();
                      if (i < 0 || i >= measurements.length) {
                        return const SizedBox.shrink();
                      }
                      // Show first, last, and middle when many points.
                      final last = measurements.length - 1;
                      if (measurements.length > 4 &&
                          i != 0 &&
                          i != last &&
                          i != last ~/ 2) {
                        return const SizedBox.shrink();
                      }
                      final date = measurements[i].localDate;
                      final short = date.length >= 10
                          ? '${date.substring(8, 10)}/${date.substring(5, 7)}'
                          : date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          short,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: measurements.length > 2,
                  color: scheme.primary,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 3.5,
                        color: scheme.primary,
                        strokeWidth: 1.5,
                        strokeColor: scheme.surface,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: scheme.primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
