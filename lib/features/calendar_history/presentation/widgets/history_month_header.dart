import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// Month selector + optional "today" control for the History calendar chrome.
///
/// [showGoToToday] is false when the selected day is already today (less noise).
class HistoryMonthHeader extends StatelessWidget {
  const HistoryMonthHeader({
    super.key,
    required this.focusedMonth,
    required this.onMonthSelected,
    required this.onGoToToday,
    this.showGoToToday = true,
  });

  final DateTime focusedMonth;
  final ValueChanged<DateTime> onMonthSelected;
  final VoidCallback onGoToToday;

  /// When false, the today button is omitted (already on today).
  final bool showGoToToday;

  @override
  Widget build(BuildContext context) {
    final rawLocale = Localizations.maybeLocaleOf(context)?.languageCode;
    
    bool isLocaleAvailable(String? loc) {
      if (loc == null) return false;
      try {
        return DateFormat.localeExists(loc);
      } catch (_) {
        return false;
      }
    }

    final locale = isLocaleAvailable(rawLocale) ? rawLocale : null;

    String formatMonth(DateTime date) {
      if (locale != null) {
        try {
          final formatted = DateFormat.MMMM(locale).format(date);
          return formatted.isNotEmpty
              ? '${formatted[0].toUpperCase()}${formatted.substring(1)}'
              : formatted;
        } catch (_) {}
      }
      return UiStrings.monthNames[date.month - 1];
    }

    final monthLabel = formatMonth(focusedMonth);
    final year = focusedMonth.year;
    final today = DateTime.now().day;
    final l10n = context.l10n;
    final selectMonthTooltip = l10n.historySelectMonth;
    final goToTodayTooltip = l10n.historyGoToToday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: PopupMenuButton<DateTime>(
                key: const Key('history_month_selector'),
                tooltip: selectMonthTooltip,
                onSelected: onMonthSelected,
                itemBuilder: (context) {
                  final year = focusedMonth.year;
                  return List.generate(12, (i) {
                    final month = DateTime(year, i + 1);
                    final mName = formatMonth(month);
                    return PopupMenuItem(
                      value: month,
                      child: Text(
                        '$mName $year',
                      ),
                    );
                  });
                },
                child: Semantics(
                  button: true,
                  label: selectMonthTooltip,
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
          if (showGoToToday)
            Semantics(
              button: true,
              label: goToTodayTooltip,
              child: IconButton(
                key: const Key('history_today_button'),
                tooltip: goToTodayTooltip,
                onPressed: onGoToToday,
                constraints: const BoxConstraints(
                  minWidth: AppTheme.buttonMinHeight,
                  minHeight: AppTheme.buttonMinHeight,
                ),
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$today',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
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
