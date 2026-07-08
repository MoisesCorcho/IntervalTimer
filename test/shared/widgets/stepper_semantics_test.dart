import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/shared/widgets/interval_duration_picker.dart';
import 'package:interval_timer/shared/widgets/number_stepper.dart';

void main() {
  testWidgets('± buttons expose non-empty semantic labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Column(
            children: [
              NumberStepper(
                value: 3,
                min: 1,
                max: 99,
                onChanged: (_) {},
                label: 'Sets',
                semanticsLabel: 'Sets',
              ),
              IntervalDurationPicker(
                totalSeconds: 60,
                minSeconds: 1,
                maxSeconds: 5999,
                onChanged: (_) {},
                label: 'Duración trabajo',
              ),
            ],
          ),
        ),
      ),
    );

    final labels = <String>[];
    void collect(Element element) {
      final widget = element.widget;
      if (widget is Semantics) {
        final data = widget.properties;
        final label = data.label;
        if (label != null && label.isNotEmpty) {
          labels.add(label);
        }
      }
      element.visitChildren(collect);
    }

    tester.element(find.byType(Scaffold)).visitChildren(collect);

    expect(labels.any((l) => l.contains('Aumentar')), isTrue);
    expect(labels.any((l) => l.contains('Disminuir')), isTrue);
    expect(labels.where((l) => l.trim().isNotEmpty), isNotEmpty);
  });
}
