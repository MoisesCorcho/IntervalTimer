import 'package:flutter/material.dart';
import 'package:interval_timer/core/theme/app_theme.dart';

class ProgressShowcaseSlide extends StatelessWidget {
  const ProgressShowcaseSlide({super.key});

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
          // Athletic Progress & Achievement Showcase Card
          Container(
            height: 180,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.12),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Trophy & Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Primer Paso Completado!',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Medalla de Iniciación desbloqueada',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                // Metric Stats Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatBadge(
                      icon: Icons.local_fire_department,
                      color: Colors.deepOrange,
                      label: '3 Días',
                      sublabel: 'Racha Activa',
                      colorScheme: colorScheme,
                    ),
                    _StatBadge(
                      icon: Icons.bolt,
                      color: Colors.amber,
                      label: '250 kcal',
                      sublabel: 'Energía',
                      colorScheme: colorScheme,
                    ),
                    _StatBadge(
                      icon: Icons.calendar_today,
                      color: Colors.green,
                      label: '100%',
                      sublabel: 'Objetivo',
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
              'HÁBITO & LOGROS',
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
            'Constancia que se transforma en logros',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm + 2),
          // Description
          Text(
            'Calendario de consistencia, estadísticas de calorías y racha activa, registro de peso corporal y medallas para celebrar tu progreso.',
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

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.color,
    required this.label,
    required this.sublabel,
    required this.colorScheme,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String sublabel;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
