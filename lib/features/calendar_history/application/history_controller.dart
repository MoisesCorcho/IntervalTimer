import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryUiState {
  const HistoryUiState({
    required this.focusedMonth,
    required this.selectedDate,
  });

  /// First day of the visible month (day = 1).
  final DateTime focusedMonth;
  final DateTime selectedDate;

  HistoryUiState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDate,
  }) {
    return HistoryUiState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class HistoryController extends Notifier<HistoryUiState> {
  @override
  HistoryUiState build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return HistoryUiState(
      focusedMonth: DateTime(today.year, today.month),
      selectedDate: today,
    );
  }

  void selectDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    state = state.copyWith(
      selectedDate: normalized,
      focusedMonth: DateTime(normalized.year, normalized.month),
    );
  }

  /// Changes visible month; clamps selected day if invalid (e.g. 31 → last day).
  void setFocusedMonth(DateTime month) {
    final focused = DateTime(month.year, month.month);
    final lastDay = DateTime(focused.year, focused.month + 1, 0).day;
    final day = state.selectedDate.day.clamp(1, lastDay);
    final selected = DateTime(focused.year, focused.month, day);
    state = HistoryUiState(focusedMonth: focused, selectedDate: selected);
  }

  void goToToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    state = HistoryUiState(
      focusedMonth: DateTime(today.year, today.month),
      selectedDate: today,
    );
  }
}
