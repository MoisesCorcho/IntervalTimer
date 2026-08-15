import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:interval_timer/features/preset_routines/domain/models/enums.dart';
import 'package:interval_timer/features/preset_routines/domain/models/preset_routine.dart';
import 'package:interval_timer/features/preset_routines/presentation/widgets/preset_hero_carousel.dart';

void main() {
  const testPreset = PresetRoutine(
    id: 'preset_tabata_full',
    title: 'Tabata Full Body 20m',
    description: 'Rutina Tabata completa',
    category: PresetCategory.fullBody,
    difficulty: DifficultyLevel.advanced,
    isFeatured: true,
    restBetweenExercisesSeconds: 10,
    exercises: [],
  );

  testWidgets('PresetHeroCarousel renders title, difficulty, and navigates on tap', (tester) async {
    String? navigatedRoute;

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: PresetHeroCarousel(presets: const [testPreset]),
          ),
        ),
        GoRoute(
          path: '/presets/:id',
          builder: (context, state) {
            navigatedRoute = state.pathParameters['id'];
            return Scaffold(body: Text('Preset Detail: ${state.pathParameters['id']}'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tabata Full Body 20m'), findsOneWidget);
    expect(find.text('POPULAR'), findsOneWidget);

    await tester.tap(find.text('Tabata Full Body 20m'));
    await tester.pumpAndSettle();

    expect(navigatedRoute, 'preset_tabata_full');
    expect(find.text('Preset Detail: preset_tabata_full'), findsOneWidget);
  });
}
