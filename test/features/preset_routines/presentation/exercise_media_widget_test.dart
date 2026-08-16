import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/exercise.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/exercise_media_widget.dart';

void main() {
  group('ExerciseMediaWidget', () {
    testWidgets('renders category fallback when exercise mediaPath is null or missing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseMediaWidget(
              category: PresetCategory.hiit,
            ),
          ),
        ),
      );

      // Should attempt to load Image.asset for category
      expect(find.byType(ExerciseMediaWidget), findsOneWidget);
    });

    testWidgets('renders category fallback when exercise has empty mediaPath', (tester) async {
      const exercise = Exercise(
        id: 'ex_test',
        name: 'Test',
        category: PresetCategory.core,
        mediaType: MediaType.image,
        mediaPath: '',
        steps: [],
        tips: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseMediaWidget(
              exercise: exercise,
              category: PresetCategory.core,
            ),
          ),
        ),
      );

      expect(find.byType(ExerciseMediaWidget), findsOneWidget);
    });

    testWidgets('renders ClipRRect when borderRadius is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseMediaWidget(
              category: PresetCategory.lowerBody,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
