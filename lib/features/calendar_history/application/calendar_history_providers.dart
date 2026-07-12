import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interval_timer/core/utils/local_date_format.dart';
import 'package:interval_timer/data/models/session_log.dart';
import 'package:interval_timer/data/repositories/session_log_repository.dart';
import 'package:interval_timer/features/calendar_history/application/history_controller.dart';
import 'package:interval_timer/features/timer/application/timer_providers.dart';

final sessionLogRepositoryProvider = Provider<SessionLogRepository>((ref) {
  return SessionLogRepository(ref.watch(databaseProvider));
});

final historyControllerProvider =
    NotifierProvider<HistoryController, HistoryUiState>(HistoryController.new);

final sessionLogsForSelectedDayProvider =
    StreamProvider.autoDispose<List<SessionLog>>((ref) {
  final selected = ref.watch(historyControllerProvider).selectedDate;
  final localDate = LocalDateFormat.fromDateTime(selected);
  return ref.watch(sessionLogRepositoryProvider).watchByLocalDate(localDate);
});

final sessionMarkerDatesProvider =
    StreamProvider.autoDispose<Set<String>>((ref) {
  final focused = ref.watch(historyControllerProvider).focusedMonth;
  return ref
      .watch(sessionLogRepositoryProvider)
      .watchMarkerDatesForMonth(focused);
});
