import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/l10n/app_localizations.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/data/models/interval.dart';
import 'package:interval_timer/data/models/interval_type.dart';
import 'package:interval_timer/data/models/routine.dart';
import 'package:interval_timer/data/models/routine_item.dart';
import 'package:interval_timer/features/timer/application/routine_editor_controller.dart';
import 'package:interval_timer/features/timer/presentation/routine_editor_screen.dart';
import 'package:interval_timer/shared/widgets/interval_color_badge.dart';

class FakeRoutineEditorController extends RoutineEditorController {
  FakeRoutineEditorController(this._initial);
  final Routine _initial;

  @override
  Future<Routine> build() async => _initial;
}

void main() {
  final testRoutine = Routine(
    id: 'routine-1',
    name: 'Test Routine',
    createdAt: DateTime(2026, 1, 1),
    items: [
      RoutineItem.interval(
        const Interval(
          id: 'i1',
          name: 'BURPEES',
          durationSeconds: 45,
          colorArgb: 0xFF2E7D32,
          type: IntervalType.work,
        ),
      ),
      RoutineItem.interval(
        const Interval(
          id: 'i2',
          name: 'PLANK',
          durationSeconds: 30,
          colorArgb: 0xFF2E7D32,
          type: IntervalType.work,
        ),
      ),
    ],
  );

  Widget buildSubject(Routine routine) {
    return ProviderScope(
      overrides: [
        routineEditorProvider.overrideWith(
          () => FakeRoutineEditorController(routine),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(),
        home: const RoutineEditorScreen(),
      ),
    );
  }

  group('RoutineEditorScreen Interval List UI (F01 Clean Design)', () {
    testWidgets('renders clean list item with leading index, title, subtitle and NO green IntervalColorBadge', (tester) async {
      await tester.pumpWidget(buildSubject(testRoutine));
      await tester.pumpAndSettle();

      // Verify no heavy green IntervalColorBadge is rendered
      expect(find.byType(IntervalColorBadge), findsNothing);

      // Verify clean interval details
      expect(find.text('BURPEES'), findsOneWidget);
      expect(find.text('00:45'), findsOneWidget);
      expect(find.text('PLANK'), findsOneWidget);
      expect(find.text('00:30'), findsOneWidget);

      // Verify leading index markers
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Verify delete buttons
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    });

    testWidgets('renders item title and subtitle with dark theme onSurface and onSurfaceVariant colors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routineEditorProvider.overrideWith(
              () => FakeRoutineEditorController(testRoutine),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.dark,
            home: const RoutineEditorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final darkTheme = AppTheme.dark();
      final titleWidget = tester.widget<Text>(find.text('BURPEES'));
      expect(titleWidget.style?.color, equals(darkTheme.colorScheme.onSurface));

      final subtitleWidget = tester.widget<Text>(find.text('00:45'));
      expect(subtitleWidget.style?.color, equals(darkTheme.colorScheme.onSurfaceVariant));
    });

    testWidgets('dynamically switching themeMode from light to dark updates item text colors', (tester) async {
      final container = ProviderContainer(
        overrides: [
          routineEditorProvider.overrideWith(
            () => FakeRoutineEditorController(testRoutine),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.light,
            home: const RoutineEditorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lightTheme = AppTheme.light();
      final titleLight = tester.widget<Text>(find.text('BURPEES'));
      expect(titleLight.style?.color, equals(lightTheme.colorScheme.onSurface));

      // Switch theme mode to dark without starting a routine
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.dark,
            home: const RoutineEditorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final darkTheme = AppTheme.dark();
      final titleDark = tester.widget<Text>(find.text('BURPEES'));
      expect(titleDark.style?.color, equals(darkTheme.colorScheme.onSurface));
    });
  });
}
