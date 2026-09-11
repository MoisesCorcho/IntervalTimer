import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

class AudioShowcaseSlide extends StatefulWidget {
  const AudioShowcaseSlide({super.key});

  @override
  State<AudioShowcaseSlide> createState() => _AudioShowcaseSlideState();
}

class _AudioShowcaseSlideState extends State<AudioShowcaseSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
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
          // Animated Audio Waveform & Feature Badges
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Waveform Bars
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(9, (index) {
                        final phase = (index * 0.35);
                        final val = math.sin((_waveController.value * 2 * math.pi) + phase);
                        final normalizedHeight = 16.0 + (val.abs() * 38.0);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 6,
                          height: normalizedHeight,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              colorScheme.primary,
                              const Color(0xFF00BCD4),
                              index / 8,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.spacingMd),
                // Badges Row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _FeatureChip(
                      icon: Icons.record_voice_over,
                      label: 'Voz TTS',
                      colorScheme: colorScheme,
                    ),
                    _FeatureChip(
                      icon: Icons.sports,
                      label: 'SFX Gong/Campana',
                      colorScheme: colorScheme,
                    ),
                    _FeatureChip(
                      icon: Icons.music_note,
                      label: 'Music Ducking',
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ],
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
              'INMERSIÓN & FOCO',
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
            'Olvidate de mirar la pantalla',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm + 2),
          // Description
          Text(
            'Asistente por voz que anuncia cada fase, efectos de sonido deportivos de alta fidelidad y atenuación inteligente de tu música.',
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

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
