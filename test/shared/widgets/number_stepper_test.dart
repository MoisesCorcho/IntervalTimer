import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/shared/widgets/number_stepper.dart';

void main() {
  Future<void> pumpStepper(
    WidgetTester tester, {
    required int value,
    required ValueChanged<int> onChanged,
    int min = 1,
    int max = 99,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: NumberStepper(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            label: 'Sets',
          ),
        ),
      ),
    );
  }

  testWidgets('shows value and no TextField', (tester) async {
    await pumpStepper(tester, value: 3, onChanged: (_) {});

    expect(find.byKey(const Key('number_stepper_value')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('tap + / - changes value', (tester) async {
    var current = 3;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return NumberStepper(
                value: current,
                min: 1,
                max: 99,
                onChanged: (v) => setState(() => current = v),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('number_stepper_increment')));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);

    await tester.tap(find.byKey(const Key('number_stepper_decrement')));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('buttons disabled at min and max', (tester) async {
    await pumpStepper(tester, value: 1, onChanged: (_) {});

    final decMin = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('number_stepper_decrement')),
        matching: find.byType(IconButton),
      ),
    );
    expect(decMin.onPressed, isNull);

    await pumpStepper(tester, value: 99, onChanged: (_) {});
    final incMax = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('number_stepper_increment')),
        matching: find.byType(IconButton),
      ),
    );
    expect(incMax.onPressed, isNull);
  });
}
