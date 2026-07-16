import 'dart:io';

import 'package:flutter/material.dart';
import 'package:interval_timer/core/constants/ui_strings.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/duration_parser.dart';
import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';

/// Share template card matching product reference (transparent / photo / solid).
class SessionShareCard extends StatelessWidget {
  const SessionShareCard({
    super.key,
    required this.data,
    this.width = 280,
    this.height = 420,
    this.showAddPhotoPlaceholder = false,
    this.onAddPhoto,
  });

  final ShareCardData data;
  final double width;
  final double height;
  final bool showAddPhotoPlaceholder;
  final VoidCallback? onAddPhoto;

  static const designWidth = 300.0;
  static const designHeight = 460.0;

  @override
  Widget build(BuildContext context) {
    // Design at fixed size, scale to fit so PageView previews never overflow.
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: switch (data.template) {
              ShareTemplateStyle.transparent => _TransparentTemplate(
                  data: data,
                  showAddPhotoPlaceholder: showAddPhotoPlaceholder,
                  onAddPhoto: onAddPhoto,
                ),
              ShareTemplateStyle.solidDark => _SolidTemplate(
                  data: data,
                  background: const Color(0xFF1A1A1A),
                ),
              ShareTemplateStyle.solidBrand => _SolidTemplate(
                  data: data,
                  background: AppTheme.workColor,
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _TransparentTemplate extends StatelessWidget {
  const _TransparentTemplate({
    required this.data,
    required this.showAddPhotoPlaceholder,
    this.onAddPhoto,
  });

  final ShareCardData data;
  final bool showAddPhotoPlaceholder;
  final VoidCallback? onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = data.photoPath != null && data.photoPath!.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Checkerboard "transparent" base (or photo).
        if (hasPhoto)
          Image.file(
            File(data.photoPath!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _Checkerboard(),
          )
        else
          const _Checkerboard(),
        // Soft gradient for text readability
        if (hasPhoto)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Color(0x00000000),
                  Color(0xCC000000),
                ],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: _Pill(
                  label: UiStrings.sessionSummaryShareTransparent,
                  filled: false,
                ),
              ),
              const Spacer(),
              if (showAddPhotoPlaceholder && !hasPhoto && onAddPhoto != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: onAddPhoto,
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: AppTheme.spacingSm + 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_camera_outlined, size: 18),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                              UiStrings.sessionSummaryShareAddPhoto,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              _StatsOverlay(data: data, lightText: hasPhoto || true),
            ],
          ),
        ),
      ],
    );
  }
}

class _SolidTemplate extends StatelessWidget {
  const _SolidTemplate({
    required this.data,
    required this.background,
  });

  final ShareCardData data;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.local_fire_department_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _StatsOverlay(data: data, lightText: true),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _StatsOverlay extends StatelessWidget {
  const _StatsOverlay({
    required this.data,
    required this.lightText,
  });

  final ShareCardData data;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    final textColor = lightText ? Colors.white : Colors.white;
    final total = formatDurationMmSs(data.totalDurationSeconds.clamp(0, 5999));
    final work = formatDurationMmSs(data.trainingSeconds.clamp(0, 5999));
    final rest = formatDurationMmSs(data.restSeconds.clamp(0, 5999));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                color: textColor.withValues(alpha: 0.85), size: 22),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              total,
              style: TextStyle(
                color: textColor,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                height: 1,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Icon(Icons.emoji_events_outlined,
                color: textColor.withValues(alpha: 0.85), size: 22),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        _ColorChip(
          label: UiStrings.sessionSummaryShareWorkoutBadge,
          color: AppTheme.workColor,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: _StatColumn(
                value: '${data.setsCount}',
                label: UiStrings.sessionSummaryShareSets,
                chipColor: const Color(0xFF5C5C5C),
              ),
            ),
            Expanded(
              child: _StatColumn(
                value: work,
                label: UiStrings.sessionSummaryShareWork,
                chipColor: AppTheme.workColor,
              ),
            ),
            Expanded(
              child: _StatColumn(
                value: rest,
                label: UiStrings.sessionSummaryShareRest,
                chipColor: AppTheme.restColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.workColor,
                    AppTheme.restColor,
                  ],
                ),
              ),
              child: const Icon(Icons.timer_outlined,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    UiStrings.sessionSummaryShareBrand,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    UiStrings.sessionSummaryShareTagline,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.chipColor,
  });

  final String value;
  final String label;
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        _ColorChip(label: label, color: chipColor),
      ],
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? Colors.white : Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.black87 : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Checkerboard extends StatelessWidget {
  const _Checkerboard();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 16.0;
    final light = Paint()..color = const Color(0xFF3A3A3A);
    final dark = Paint()..color = const Color(0xFF2A2A2A);
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final isLight = ((x / cell).floor() + (y / cell).floor()).isEven;
        canvas.drawRect(
          Rect.fromLTWH(x, y, cell, cell),
          isLight ? light : dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
