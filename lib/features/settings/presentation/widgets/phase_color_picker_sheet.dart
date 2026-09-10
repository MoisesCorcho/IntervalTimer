import 'package:flutter/material.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/contrast_text_color.dart';
import 'package:interval_timer/shared/widgets/app_modal_bottom_sheet.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';

import 'package:interval_timer/shared/widgets/countdown_ring.dart';

/// Opens the [PhaseColorPickerSheet] in the canonical design system modal bottom sheet.
Future<void> showPhaseColorPickerSheet({
  required BuildContext context,
  required String title,
  required Color initialColor,
  required Color defaultColor,
  required ValueChanged<Color> onColorSelected,
}) {
  return showAppModalBottomSheet(
    context: context,
    builder: (sheetContext) => PhaseColorPickerSheet(
      title: title,
      initialColor: initialColor,
      defaultColor: defaultColor,
      onColorSelected: onColorSelected,
    ),
  );
}

/// Interactive sheet for picking an athletic phase color from [AppTheme.phaseColorPresets].
///
/// Features:
/// - Real-time animated miniature mockup of the TimerExecutionScreen reflecting the selected background and WCAG [contrastTextColor].
/// - 5x2 tactile swatch grid of 10 curated athletic colors.
/// - One-tap reset to default.
class PhaseColorPickerSheet extends StatefulWidget {
  const PhaseColorPickerSheet({
    super.key,
    required this.title,
    required this.initialColor,
    required this.defaultColor,
    required this.onColorSelected,
  });

  final String title;
  final Color initialColor;
  final Color defaultColor;
  final ValueChanged<Color> onColorSelected;

  @override
  State<PhaseColorPickerSheet> createState() => _PhaseColorPickerSheetState();
}

class _PhaseColorPickerSheetState extends State<PhaseColorPickerSheet>
    with SingleTickerProviderStateMixin {
  late Color _selectedColor;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const textColor = Colors.white;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Exact miniature animated mockup of TimerExecutionScreen
            IgnorePointer(
              key: const Key('preview_mockup_ignore_pointer'),
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  final remainingSeconds =
                      ((1.0 - _animController.value) * 8).ceil().clamp(1, 8);
                  final timeText = '00:0$remainingSeconds';
                  final ringFraction =
                      (1.0 - _animController.value).clamp(0.0, 1.0);

                  return Container(
                    key: const Key('phase_color_preview_card'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm + 4,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.buttonShadowFor(context),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Miniature Top Bar
                        Row(
                          key: const Key('preview_mockup_top_bar'),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.close,
                              color: textColor.withValues(alpha: 0.8),
                              size: 18,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.remainingLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.8),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                Text(
                                  '04:30',
                                  style: TextStyle(
                                    color: textColor,
                                    fontFamily: 'RobotoMono',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.tune,
                              color: textColor.withValues(alpha: 0.8),
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingSm),

                        // Phase title & Progress
                        Text(
                          widget.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.intervalProgress(1, 8),
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),

                        // Animated Countdown Ring
                        CountdownRing(
                          size: 120,
                          strokeWidth: 8,
                          remainingFraction: ringFraction,
                          color: textColor,
                          child: Center(
                            child: Text(
                              timeText,
                              key: const Key('preview_mockup_countdown'),
                              style: TextStyle(
                                color: textColor,
                                fontFamily: 'RobotoMono',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),

                        // Next segment banner
                        Container(
                          key: const Key('preview_mockup_next_segment'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMd,
                            vertical: AppTheme.spacingXs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: textColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.nextInterval,
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.75),
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    widget.title
                                                .toLowerCase()
                                                .contains('trabajo') ||
                                            widget.title
                                                .toLowerCase()
                                                .contains('work')
                                        ? l10n.restColorTitle
                                        : l10n.workColorTitle,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '00:15',
                                style: TextStyle(
                                  color: textColor.withValues(alpha: 0.85),
                                  fontFamily: 'RobotoMono',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),

                        // Control Bar Mockup
                        Row(
                          key: const Key('preview_mockup_controls'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.keyboard_double_arrow_left_rounded,
                              color: textColor.withValues(alpha: 0.8),
                              size: 22,
                            ),
                            const SizedBox(width: AppTheme.spacingLg),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: textColor.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: textColor.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.pause_rounded,
                                color: textColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingLg),
                            Icon(
                              Icons.keyboard_double_arrow_right_rounded,
                              color: textColor.withValues(alpha: 0.8),
                              size: 22,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // 10-preset athletic palette grid (5x2)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final color in AppTheme.phaseColorPresets)
                  _ColorSwatchTile(
                    color: color,
                    isSelected: color.toARGB32() == _selectedColor.toARGB32(),
                    onTap: () => setState(() => _selectedColor = color),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Action row: Reset & Save
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    key: const Key('reset_color_button'),
                    onPressed: () {
                      setState(() => _selectedColor = widget.defaultColor);
                    },
                    child: Text(l10n.resetToDefault),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: AppPrimaryButton(
                    key: const Key('save_color_button'),
                    onPressed: () {
                      widget.onColorSelected(_selectedColor);
                      Navigator.of(context).pop();
                    },
                    label: l10n.saveColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatchTile extends StatelessWidget {
  const _ColorSwatchTile({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = contrastTextColor(color);

    return InkWell(
      key: Key('color_swatch_${color.toARGB32()}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: isSelected
              ? Border.all(color: fg, width: 3)
              : Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
          boxShadow: isSelected ? AppTheme.buttonShadowFor(context) : null,
        ),
        child: isSelected
            ? Center(
                child: Icon(
                  Icons.check_rounded,
                  color: fg,
                  size: 24,
                ),
              )
            : null,
      ),
    );
  }
}
