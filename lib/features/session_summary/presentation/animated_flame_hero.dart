import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

/// Centered procedural living flame with floating embers and expanding rings
/// for workout completion and streak celebration (F16 victory hero).
///
/// Replaces the static Material icon with a multi-layered procedural fire
/// featuring organic Bézier flicker, ambient heat aura, and floating glowing
/// embers, executing at native 60/120 FPS with zero external dependencies.
class AnimatedFlameHero extends StatelessWidget {
  const AnimatedFlameHero({
    super.key,
    required this.animation,
    this.size = 120,
  });

  /// 0–1 continuous progress of flame dance & ring pulse (repeating controller).
  final Animation<double> animation;

  /// Diameter of the central circular badge.
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;

        return SizedBox(
          width: size * 2.4,
          height: size * 2.4,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Expanding shockwave pulse rings
              for (var i = 0; i < 3; i++)
                _PulseRing(
                  progress: (progress + i / 3.0) % 1.0,
                  maxDiameter: size * 2.2,
                ),

              // 2. White elevated badge containing the living flame
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6D00).withValues(alpha: 0.28),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient heat aura
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _FlameAuraPainter(progress: progress),
                        ),
                      ),
                      // Multi-layered procedural animated flame
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ProceduralFlamePainter(progress: progress),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Floating glowing embers that escape upward over the badge
              Positioned(
                top: (size * 2.4 - size) / 2 - (size * 0.16),
                width: size,
                height: size * 1.25,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _FloatingEmbersPainter(progress: progress),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Expanding shockwave ring that pulses outward from the badge.
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

/// Ambient radial heat aura that breathes softly behind the flame.
class _FlameAuraPainter extends CustomPainter {
  _FlameAuraPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    final pulse = 0.92 + 0.08 * math.sin(t);
    final center = Offset(size.width * 0.5, size.height * 0.62);
    final radius = size.width * 0.42 * pulse;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF9100).withValues(alpha: 0.32),
          const Color(0xFFFF3D00).withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_FlameAuraPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Procedural multi-layer flame painter with organic dual-crest flickers.
class _ProceduralFlamePainter extends CustomPainter {
  _ProceduralFlamePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final baseY = size.height * 0.77;
    final t = progress * 2 * math.pi;

    // 1. Outer Flame (Fiery Red to Deep Orange)
    final outerW = size.width * 0.46;
    final outerH = size.height * 0.56;
    final outerSway = math.sin(t) * (outerW * 0.09);
    final outerTongueSway = math.sin(t + 1.2) * (outerW * 0.08);
    final outerFlicker = math.cos(t * 2) * (outerH * 0.04);

    final outerPath = _buildFlamePath(
      cx: cx,
      baseY: baseY,
      width: outerW,
      height: outerH + outerFlicker,
      mainTipSway: outerSway,
      tongueSway: outerTongueSway,
      bulgeLeft: math.sin(t * 1.5) * (outerW * 0.04),
      bulgeRight: math.cos(t * 1.5) * (outerW * 0.04),
    );

    final outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: const [
          Color(0xFFE62D00),
          Color(0xFFFF5722),
          Color(0xFFFF9100),
        ],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(Rect.fromLTWH(cx - outerW, baseY - outerH, outerW * 2, outerH));

    canvas.drawPath(outerPath, outerPaint);

    // 2. Middle Flame (Vivid Amber-Gold Lick, phase-lagged for organic fluidity)
    final midW = outerW * 0.72;
    final midH = outerH * 0.74;
    final midSway = math.sin(t + 1.6) * (midW * 0.11);
    final midTongueSway = math.cos(t + 0.8) * (midW * 0.09);
    final midFlicker = math.sin(t * 2.5) * (midH * 0.04);

    final midPath = _buildFlamePath(
      cx: cx,
      baseY: baseY - (outerH * 0.03),
      width: midW,
      height: midH + midFlicker,
      mainTipSway: midSway,
      tongueSway: midTongueSway,
      bulgeLeft: math.sin(t * 2) * (midW * 0.04),
      bulgeRight: math.cos(t * 2) * (midW * 0.04),
    );

    final midPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: const [
          Color(0xFFFF6D00),
          Color(0xFFFFAB00),
          Color(0xFFFFD600),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(cx - midW, baseY - midH, midW * 2, midH));

    canvas.drawPath(midPath, midPaint);

    // 3. Core Flame (White-hot glowing nucleus)
    final coreW = outerW * 0.38;
    final coreH = outerH * 0.44;
    final coreSway = math.sin(t + 2.5) * (coreW * 0.08);
    final coreFlicker = math.sin(t * 3.0) * (coreH * 0.03);

    final corePath = _buildCorePath(
      cx: cx,
      baseY: baseY - (outerH * 0.04),
      width: coreW,
      height: coreH + coreFlicker,
      sway: coreSway,
    );

    final corePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: const [
          Color(0xFFFFD600),
          Color(0xFFFFF9C4),
          Colors.white,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(cx - coreW, baseY - coreH, coreW * 2, coreH));

    canvas.drawPath(corePath, corePaint);
  }

  /// Builds a dynamic dual-crest flame silhouette (main high peak + playful left tongue).
  Path _buildFlamePath({
    required double cx,
    required double baseY,
    required double width,
    required double height,
    required double mainTipSway,
    required double tongueSway,
    required double bulgeLeft,
    required double bulgeRight,
  }) {
    final path = Path();
    final mainTip = Offset(cx + mainTipSway, baseY - height);
    final tongueTip = Offset(cx - width * 0.32 + tongueSway, baseY - height * 0.64);
    final valley = Offset(cx - width * 0.08, baseY - height * 0.48);

    // Start at main peak
    path.moveTo(mainTip.dx, mainTip.dy);

    // Right flank: main peak down to right shoulder and belly
    path.cubicTo(
      cx + width * 0.22 + mainTipSway * 0.4,
      baseY - height * 0.84,
      cx + width * 0.50 + bulgeRight,
      baseY - height * 0.58,
      cx + width * 0.46 + bulgeRight,
      baseY - height * 0.32,
    );

    // Right belly smoothly wrapping down to bottom base
    path.cubicTo(
      cx + width * 0.42,
      baseY + height * 0.05,
      cx + width * 0.16,
      baseY + height * 0.06,
      cx,
      baseY + height * 0.06,
    );

    // Bottom base wrapping into left belly
    path.cubicTo(
      cx - width * 0.16,
      baseY + height * 0.06,
      cx - width * 0.42,
      baseY + height * 0.05,
      cx - width * 0.46 + bulgeLeft,
      baseY - height * 0.32,
    );

    // Left flank rising to the left secondary tongue
    path.cubicTo(
      cx - width * 0.50 + bulgeLeft,
      baseY - height * 0.46,
      cx - width * 0.40,
      baseY - height * 0.56,
      tongueTip.dx,
      tongueTip.dy,
    );

    // Inward dip from left tongue into central valley
    path.cubicTo(
      cx - width * 0.24,
      baseY - height * 0.60,
      cx - width * 0.14,
      baseY - height * 0.50,
      valley.dx,
      valley.dy,
    );

    // Re-ascent from valley back to main peak
    path.cubicTo(
      cx - width * 0.02,
      baseY - height * 0.66,
      cx + mainTipSway * 0.3,
      baseY - height * 0.88,
      mainTip.dx,
      mainTip.dy,
    );

    path.close();
    return path;
  }

  /// Builds a smooth tear-drop core flame at the bottom-center.
  Path _buildCorePath({
    required double cx,
    required double baseY,
    required double width,
    required double height,
    required double sway,
  }) {
    final path = Path();
    final tip = Offset(cx + sway, baseY - height);

    path.moveTo(tip.dx, tip.dy);

    // Right side
    path.cubicTo(
      cx + width * 0.25,
      baseY - height * 0.70,
      cx + width * 0.48,
      baseY - height * 0.35,
      cx + width * 0.38,
      baseY,
    );

    // Bottom arc
    path.cubicTo(
      cx + width * 0.20,
      baseY + height * 0.05,
      cx - width * 0.20,
      baseY + height * 0.05,
      cx - width * 0.38,
      baseY,
    );

    // Left side returning to tip
    path.cubicTo(
      cx - width * 0.48,
      baseY - height * 0.35,
      cx - width * 0.25,
      baseY - height * 0.70,
      tip.dx,
      tip.dy,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_ProceduralFlamePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Floating embers / spark particles that drift upward and fade out.
class _FloatingEmbersPainter extends CustomPainter {
  _FloatingEmbersPainter({required this.progress});

  final double progress;

  static const _embers = [
    _EmberSpec(offset: 0.05, xRel: -0.15, drift: 9.0, radius: 2.8),
    _EmberSpec(offset: 0.19, xRel: 0.12, drift: -8.0, radius: 2.2),
    _EmberSpec(offset: 0.34, xRel: -0.06, drift: 12.0, radius: 3.2),
    _EmberSpec(offset: 0.48, xRel: 0.20, drift: -10.0, radius: 2.0),
    _EmberSpec(offset: 0.63, xRel: -0.22, drift: 11.0, radius: 2.6),
    _EmberSpec(offset: 0.77, xRel: 0.04, drift: -9.0, radius: 3.4),
    _EmberSpec(offset: 0.91, xRel: 0.14, drift: 8.0, radius: 1.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final startY = size.height * 0.78;
    final endY = size.height * 0.12;
    final travelDistance = startY - endY;

    for (final spec in _embers) {
      final t = (progress + spec.offset) % 1.0;
      final y = startY - (t * travelDistance);
      final driftX = math.sin(t * math.pi * 2 + spec.drift) * spec.drift;
      final x = cx + (spec.xRel * size.width) + driftX;

      // Bell-curve opacity: 0 at birth, peak 1.0 at midpoint, 0 at top
      final opacity = math.sin(t * math.pi).clamp(0.0, 1.0);
      final radius = spec.radius * (0.8 + 0.3 * math.sin(t * math.pi));

      // Color transitions from white-gold to vivid fiery orange
      final color = Color.lerp(
        const Color(0xFFFFF59D),
        const Color(0xFFFF5722),
        t,
      )!.withValues(alpha: opacity * 0.90);

      final paint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), radius, paint);

      // Subtle glow halo around ember
      final glowPaint = Paint()
        ..color = const Color(0xFFFF9100).withValues(alpha: opacity * 0.35);
      canvas.drawCircle(Offset(x, y), radius * 1.8, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_FloatingEmbersPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _EmberSpec {
  const _EmberSpec({
    required this.offset,
    required this.xRel,
    required this.drift,
    required this.radius,
  });

  final double offset;
  final double xRel;
  final double drift;
  final double radius;
}
