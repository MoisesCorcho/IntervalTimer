import 'package:flutter/material.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/contrast_text_color.dart';
import 'package:interval_timer/shared/widgets/app_modal_bottom_sheet.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';

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
/// - Real-time live preview canvas reflecting the selected background and WCAG [contrastTextColor].
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

class _PhaseColorPickerSheetState extends State<PhaseColorPickerSheet> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textColor = contrastTextColor(_selectedColor);

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

            // Live interactive preview card
            Container(
              key: const Key('phase_color_preview_card'),
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.buttonShadowFor(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FASE 1 / 8',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    '00:45',
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'RobotoMono',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.title.toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_double_arrow_left_rounded,
                        color: textColor.withValues(alpha: 0.85),
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Icon(
                        Icons.pause_rounded,
                        color: textColor,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        color: textColor.withValues(alpha: 0.85),
                        size: 20,
                      ),
                    ],
                  ),
                ],
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
