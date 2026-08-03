import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/workout_builder/presentation/widgets/workout_rounds_list_chip.dart';

void main() {
  testWidgets('rounds chip updates surface colors when theme brightness flips',
      (tester) async {
    final brightness = ValueNotifier(Brightness.light);

    await tester.pumpWidget(
      ValueListenableBuilder<Brightness>(
        valueListenable: brightness,
        builder: (context, value, _) {
          return MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode:
                value == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
            home: const Scaffold(
              body: Center(
                child: WorkoutRoundsListChip(
                  workoutId: 'w-1',
                  rounds: 3,
                ),
              ),
            ),
          );
        },
      ),
    );

    final lightChip = tester.widget<Chip>(
      find.byKey(const Key('workout_rounds_chip_w-1')),
    );
    final lightBg = lightChip.backgroundColor;
    final lightLabel = lightChip.labelStyle?.color;

    brightness.value = Brightness.dark;
    await tester.pumpAndSettle();

    final darkChip = tester.widget<Chip>(
      find.byKey(const Key('workout_rounds_chip_w-1')),
    );
    final darkBg = darkChip.backgroundColor;
    final darkLabel = darkChip.labelStyle?.color;

    expect(lightBg, isNotNull);
    expect(darkBg, isNotNull);
    expect(darkBg, isNot(equals(lightBg)));
    expect(darkLabel, isNot(equals(lightLabel)));
    expect(find.text('3 rondas'), findsOneWidget);
  });
}
