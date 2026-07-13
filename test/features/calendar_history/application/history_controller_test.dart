import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/calendar_history/application/calendar_history_providers.dart';

void main() {
  test('setFocusedMonth clamps day 31 into shorter month (R5)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(historyControllerProvider.notifier);
    notifier.selectDay(DateTime(2026, 1, 31));
    notifier.setFocusedMonth(DateTime(2026, 2));

    final state = container.read(historyControllerProvider);
    expect(state.focusedMonth.month, 2);
    expect(state.selectedDate.day, 28);
    expect(state.selectedDate.month, 2);
  });

  test('goToToday selects today and current month (R6)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(historyControllerProvider.notifier);
    notifier.setFocusedMonth(DateTime(2024, 3));
    notifier.goToToday();

    final now = DateTime.now();
    final state = container.read(historyControllerProvider);
    expect(state.selectedDate.year, now.year);
    expect(state.selectedDate.month, now.month);
    expect(state.selectedDate.day, now.day);
    expect(state.focusedMonth.month, now.month);
  });
}
