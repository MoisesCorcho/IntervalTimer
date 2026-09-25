import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/shared/widgets/countdown_ring.dart';

class TimerShowcaseSlide extends StatefulWidget {
  const TimerShowcaseSlide({super.key});

  @override
  State<TimerShowcaseSlide> createState() => _TimerShowcaseSlideState();
}

class _TimerShowcaseSlideState extends State<TimerShowcaseSlide>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _cycleController;

  static const int _workDurationMs = 3000;
  static const int _restDurationMs = 2000;
  static const int _totalDurationMs = _workDurationMs + _restDurationMs;
  static const double _workRatio = _workDurationMs / _totalDurationMs;
  static const double _restRatio = _restDurationMs / _totalDurationMs;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.02).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    _cycleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalDurationMs),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Animated Hero Ring Showcase
          ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _cycleController,
              builder: (context, _) {
                final value = _cycleController.value;
                final bool isWork = value < _workRatio;
                final Color phaseColor = isWork ? AppTheme.workColor : AppTheme.restColor;
                final String phaseLabel = isWork ? 'TRABAJO' : 'DESCANSO';

                final double remainingFraction;
                final int remainingSeconds;

                if (isWork) {
                  final workProgress = value / _workRatio;
                  remainingFraction = (1.0 - workProgress).clamp(0.0, 1.0);
                  remainingSeconds = (remainingFraction * 3).ceil().clamp(1, 3);
                } else {
                  final restProgress = (value - _workRatio) / _restRatio;
                  remainingFraction = (1.0 - restProgress).clamp(0.0, 1.0);
                  remainingSeconds = (remainingFraction * 2).ceil().clamp(1, 2);
                }

                final formattedTime = '00:${remainingSeconds.toString().padLeft(2, '0')}';

                return Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: phaseColor.withValues(alpha: 0.2),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: CountdownRing(
                    remainingFraction: remainingFraction,
                    color: phaseColor,
                    size: 170,
                    strokeWidth: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm + 2,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: phaseColor.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            phaseLabel,
                            style: TextStyle(
                              color: phaseColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedTime,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Ronda 1/8',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          // Tag Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingXs + 2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'PRECISIÓN & CONTROL',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Headline
          Text(
            'Entrená con precisión absoluta',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm + 2),
          // Description
          Text(
            'Temporizador de intervalos ergonómico y estructurado con descansos exactos para HIIT, Tabata y entrenamientos por ejercicios.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.72),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
      ),
    );
  }
}
