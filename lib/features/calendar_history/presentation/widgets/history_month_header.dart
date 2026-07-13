import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';

class HistoryMonthHeader extends StatelessWidget {
  const HistoryMonthHeader({
    super.key,
    required this.focusedMonth,
    required this.onMonthSelected,
    required this.onGoToToday,
  });

  final DateTime focusedMonth;
  final ValueChanged<DateTime> onMonthSelected;
  final VoidCallback onGoToToday;

  @override
  Widget build(BuildContext context) {
    final monthLabel = UiStrings.monthNames[focusedMonth.month - 1];
    final year = focusedMonth.year;
    final today = DateTime.now().day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: PopupMenuButton<DateTime>(
                key: const Key('history_month_selector'),
                tooltip: UiStrings.historySelectMonth,
                onSelected: onMonthSelected,
                itemBuilder: (context) {
                  final year = focusedMonth.year;
                  return List.generate(12, (i) {
                    final month = DateTime(year, i + 1);
                    return PopupMenuItem(
                      value: month,
                      child: Text(
                        '${UiStrings.monthNames[i]} $year',
                      ),
                    );
                  });
                },
                child: Semantics(
                  button: true,
                  label: UiStrings.historySelectMonth,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        year == DateTime.now().year
                            ? monthLabel
                            : '$monthLabel $year',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.expand_more),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: UiStrings.historyGoToToday,
            child: IconButton(
              key: const Key('history_today_button'),
              tooltip: UiStrings.historyGoToToday,
              onPressed: onGoToToday,
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.calendar_today_outlined),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$today',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
