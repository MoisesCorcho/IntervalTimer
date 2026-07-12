import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryCalendar extends StatelessWidget {
  const HistoryCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.markerDates,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Set<String> markerDates;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  static String _key(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final focused = DateTime(focusedMonth.year, focusedMonth.month, 1);

    return TableCalendar(
      key: const Key('history_table_calendar'),
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: focused,
      selectedDayPredicate: (day) => isSameDay(day, selectedDate),
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerVisible: false,
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        selectedDecoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        selectedTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        todayDecoration: BoxDecoration(
          border: Border.all(color: scheme.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        todayTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        defaultDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        weekendDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        outsideDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (!markerDates.contains(_key(day))) return null;
          return Positioned(
            bottom: 2,
            child: Icon(
              Icons.fitness_center,
              size: 12,
              color: isSameDay(day, selectedDate)
                  ? scheme.onPrimary
                  : scheme.tertiary,
            ),
          );
        },
      ),
    );
  }
}
