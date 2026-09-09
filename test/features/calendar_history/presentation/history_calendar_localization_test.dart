import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/features/calendar_history/presentation/widgets/history_calendar.dart';
import 'package:interval_timer/features/calendar_history/presentation/widgets/history_month_header.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
    await initializeDateFormatting('en', null);
  });

  Widget buildTestableWidget({
    required Locale locale,
    required Widget child,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('History Month and Weekday Localization (R9)', () {
    testWidgets('renders month header and weekdays in Spanish', (tester) async {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, 1, 15);
      final pastMonth = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        buildTestableWidget(
          locale: const Locale('es'),
          child: Column(
            children: [
              HistoryMonthHeader(
                focusedMonth: currentMonth,
                onMonthSelected: (_) {},
                onGoToToday: () {},
              ),
              HistoryMonthHeader(
                focusedMonth: pastMonth,
                onMonthSelected: (_) {},
                onGoToToday: () {},
              ),
              Expanded(
                child: HistoryCalendar(
                  focusedMonth: currentMonth,
                  selectedDate: currentMonth,
                  markerDates: const {},
                  onDaySelected: (_, __) {},
                  onPageChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Month name in Spanish: current year shows month name only, past year shows year
      expect(find.text('Enero'), findsOneWidget);
      expect(find.text('Enero 2024'), findsOneWidget);

      // Weekdays in Spanish
      expect(find.text('LUN'), findsOneWidget);
      expect(find.text('MAR'), findsOneWidget);
      expect(find.text('MIÉ'), findsOneWidget);
      expect(find.text('JUE'), findsOneWidget);
      expect(find.text('VIE'), findsOneWidget);
      expect(find.text('SÁB'), findsOneWidget);
      expect(find.text('DOM'), findsOneWidget);
    });

    testWidgets('renders month header and weekdays in English', (tester) async {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, 1, 15);
      final pastMonth = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        buildTestableWidget(
          locale: const Locale('en'),
          child: Column(
            children: [
              HistoryMonthHeader(
                focusedMonth: currentMonth,
                onMonthSelected: (_) {},
                onGoToToday: () {},
              ),
              HistoryMonthHeader(
                focusedMonth: pastMonth,
                onMonthSelected: (_) {},
                onGoToToday: () {},
              ),
              Expanded(
                child: HistoryCalendar(
                  focusedMonth: currentMonth,
                  selectedDate: currentMonth,
                  markerDates: const {},
                  onDaySelected: (_, __) {},
                  onPageChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Month name in English: current year shows month name only, past year shows year
      expect(find.text('January'), findsOneWidget);
      expect(find.text('January 2024'), findsOneWidget);

      // Weekdays in English
      expect(find.text('MON'), findsOneWidget);
      expect(find.text('TUE'), findsOneWidget);
      expect(find.text('WED'), findsOneWidget);
      expect(find.text('THU'), findsOneWidget);
      expect(find.text('FRI'), findsOneWidget);
      expect(find.text('SAT'), findsOneWidget);
      expect(find.text('SUN'), findsOneWidget);
    });
  });
}
