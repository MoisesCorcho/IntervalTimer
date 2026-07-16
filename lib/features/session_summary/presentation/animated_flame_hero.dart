import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// Centered fire icon with expanding translucent rings (F16 intro animation).
class AnimatedFlameHero extends StatefulWidget {
  const AnimatedFlameHero({
    super.key,
    required this.animation,
    this.size = 120,
  });

  /// 0–1 progress of ring pulse (typically repeating).
  final Animation<double> animation;
  final double size;

  @override
  State<AnimatedFlameHero> createState() => _AnimatedFlameHeroState();
}

class _AnimatedFlameHeroState extends State<AnimatedFlameHero> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 2.4,
          height: widget.size * 2.4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                _PulseRing(
                  progress: (widget.animation.value + i / 3) % 1.0,
                  maxDiameter: widget.size * 2.2,
                ),
              child!,
            ],
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x33FFFFFF),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          Icons.local_fire_department_rounded,
          size: widget.size * 0.52,
          color: const Color(0xFFFF6D00),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.progress,
    required this.maxDiameter,
  });

  final double progress;
  final double maxDiameter;

  @override
  Widget build(BuildContext context) {
    final diameter = maxDiameter * (0.35 + progress * 0.65);
    final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.45;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: AppTheme.spacingSm * 0.6,
        ),
      ),
    );
  }
}
