import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/features/session_summary/presentation/animated_flame_hero.dart';

void main() {
  group('AnimatedFlameHero', () {
    testWidgets('renders CustomPaint and pulse rings without throwing',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: _TestFlameWrapper(),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedFlameHero), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Advance animation frames to verify smooth tick rendering
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets('respects size parameter for badge dimensioning',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: _TestFlameWrapper(
                size: 100,
              ),
            ),
          ),
        ),
      );

      final heroFinder = find.byType(AnimatedFlameHero);
      expect(heroFinder, findsOneWidget);
      final heroWidget = tester.widget<AnimatedFlameHero>(heroFinder);
      expect(heroWidget.size, 100.0);
    });

    testWidgets('cycles through full animation loop cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: _TestFlameWrapper(
                size: 120,
              ),
            ),
          ),
        ),
      );

      // Pump through multiple frames across the 2-second repeat cycle
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.byType(AnimatedFlameHero), findsOneWidget);
    });
  });
}

class _TestFlameWrapper extends StatefulWidget {
  const _TestFlameWrapper({
    this.size = 120,
  });

  final double size;

  @override
  State<_TestFlameWrapper> createState() => _TestFlameWrapperState();
}

class _TestFlameWrapperState extends State<_TestFlameWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedFlameHero(
      animation: _controller,
      size: widget.size,
    );
  }
}
