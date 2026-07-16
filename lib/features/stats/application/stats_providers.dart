import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';
import 'package:interval_timer/features/stats/domain/stats_models.dart';
import 'package:interval_timer/features/stats/domain/stats_service.dart';
import 'package:interval_timer/features/stats/domain/weight_reader.dart';

final statsServiceProvider = Provider<StatsService>((ref) {
  return const StatsService();
});

/// F15 can override this with a reader that returns the last registered weight.
final weightReaderProvider = Provider<WeightReader>((ref) {
  return const DefaultWeightReader();
});

final userWeightKgProvider = Provider<WeightReading>((ref) {
  return ref.watch(weightReaderProvider).read();
});

/// All session logs for stats; refreshes when repo mutates (R8).
final sessionLogsForStatsProvider =
    StreamProvider.autoDispose<List<SessionLog>>((ref) {
  return ref.watch(sessionLogRepositoryProvider).watchAll();
});

class ChartPeriodNotifier extends Notifier<ChartPeriod> {
  @override
  ChartPeriod build() => ChartPeriod.week;

  void setPeriod(ChartPeriod period) => state = period;
}

final chartPeriodProvider =
    NotifierProvider<ChartPeriodNotifier, ChartPeriod>(ChartPeriodNotifier.new);

final statsSummaryProvider =
    Provider.autoDispose<AsyncValue<StatsSummary>>((ref) {
  final logsAsync = ref.watch(sessionLogsForStatsProvider);
  final focusedMonth = ref.watch(historyControllerProvider).focusedMonth;
  final weight = ref.watch(userWeightKgProvider);
  final service = ref.watch(statsServiceProvider);

  return logsAsync.when(
    data: (logs) => AsyncValue.data(
      service.summarize(
        logs,
        focusedMonth: focusedMonth,
        now: DateTime.now(),
        weightKg: weight.weightKg,
        isWeightEstimated: weight.isEstimated,
      ),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

final activityChartProvider =
    Provider.autoDispose<AsyncValue<List<DayMinutes>>>((ref) {
  final logsAsync = ref.watch(sessionLogsForStatsProvider);
  final period = ref.watch(chartPeriodProvider);
  final focusedMonth = ref.watch(historyControllerProvider).focusedMonth;
  final service = ref.watch(statsServiceProvider);

  return logsAsync.when(
    data: (logs) {
      final now = DateTime.now();
      final series = switch (period) {
        ChartPeriod.week => service.weekSeries(logs, now: now),
        ChartPeriod.month =>
          service.monthSeries(logs, focusedMonth: focusedMonth),
      };
      return AsyncValue.data(series);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
