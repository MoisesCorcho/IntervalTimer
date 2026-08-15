import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/exercise_technique_bottom_sheet.dart';

void main() {
  testWidgets('ExerciseTechniqueBottomSheet renders title, steps, and tips', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const exercise = Exercise(
      id: 'ex_pushups',
      name: 'Pushups',
      category: PresetCategory.upperBody,
      mediaType: MediaType.image,
      mediaPath: '',
      steps: [
        'Colócate en posición de plancha.',
        'Baja el pecho cerca del suelo.',
      ],
      tips: [
        'Mantén la espalda recta.',
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => ExerciseTechniqueBottomSheet.show(context, exercise),
                child: const Text('Open Modal'),
              );
            },
          ),
        ),
      ),
    );

    // Open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Verify exercise details are rendered
    expect(find.text('Pushups'), findsOneWidget);
    expect(find.text('Tren Superior'), findsOneWidget);
    expect(find.text('Colócate en posición de plancha.'), findsOneWidget);
    expect(find.text('Baja el pecho cerca del suelo.'), findsOneWidget);
    expect(find.text('Mantén la espalda recta.'), findsOneWidget);

    // Close modal
    final closeButton = find.byKey(const Key('close_technique_sheet_button'));
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    expect(find.text('Pushups'), findsNothing);
  });
}
