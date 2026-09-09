import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
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
    final rawLocale = Localizations.maybeLocaleOf(context)?.languageCode;

    bool isLocaleAvailable(String? loc) {
      if (loc == null) return false;
      try {
        return DateFormat.localeExists(loc);
      } catch (_) {
        return false;
      }
    }

    final calendarLocale = isLocaleAvailable(rawLocale) ? rawLocale : null;

    return TableCalendar(
      key: const Key('history_table_calendar'),
      locale: calendarLocale,
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
      // Custom cells own number + marker layout; keep decorations minimal.
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: true,
        isTodayHighlighted: false,
        markersMaxCount: 0,
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
        dowBuilder: (context, day) {
          String label;
          if (isLocaleAvailable(rawLocale)) {
            try {
              label = DateFormat.E(rawLocale!)
                  .format(day)
                  .toUpperCase()
                  .replaceAll('.', '');
            } catch (_) {
              label = UiStrings.weekdayShort[day.weekday - 1];
            }
          } else {
            label = UiStrings.weekdayShort[day.weekday - 1];
          }
          return Center(
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
        defaultBuilder: (context, day, focusedDay) =>
            _DayCell(day: day, selected: false, today: false, outside: false, hasMarker: markerDates.contains(_key(day))),
        todayBuilder: (context, day, focusedDay) =>
            _DayCell(day: day, selected: isSameDay(day, selectedDate), today: true, outside: false, hasMarker: markerDates.contains(_key(day))),
        selectedBuilder: (context, day, focusedDay) =>
            _DayCell(day: day, selected: true, today: isSameDay(day, DateTime.now()), outside: false, hasMarker: markerDates.contains(_key(day))),
        outsideBuilder: (context, day, focusedDay) =>
            _DayCell(day: day, selected: false, today: false, outside: true, hasMarker: markerDates.contains(_key(day))),
      ),
    );
  }
}

/// Number top-left, activity icon bottom-right so neither is clipped.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.today,
    required this.outside,
    required this.hasMarker,
  });

  final DateTime day;
  final bool selected;
  final bool today;
  final bool outside;
  final bool hasMarker;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Always fill the cell so days read as tiles, not floating numbers.
    final Color bg;
    if (selected) {
      bg = scheme.primary;
    } else if (outside) {
      bg = scheme.surfaceContainerHighest.withValues(alpha: 0.45);
    } else {
      bg = scheme.surfaceContainerHighest;
    }

    final Border? border = (!selected && today)
        ? Border.all(color: scheme.primary, width: 1.5)
        : null;

    Color numberColor;
    if (selected) {
      numberColor = scheme.onPrimary;
    } else if (outside) {
      numberColor = scheme.onSurface.withValues(alpha: 0.38);
    } else {
      numberColor = scheme.onSurface;
    }

    final iconColor = selected
        ? scheme.onPrimary
        : outside
            ? scheme.tertiary.withValues(alpha: 0.5)
            : scheme.tertiary;

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 3,
            left: 5,
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: numberColor,
                fontWeight: selected || today ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                height: 1.1,
              ),
            ),
          ),
          if (hasMarker)
            Positioned(
              bottom: 3,
              right: 4,
              child: Icon(
                Icons.fitness_center,
                size: 14,
                color: iconColor,
              ),
            ),
        ],
      ),
    );
  }
}
