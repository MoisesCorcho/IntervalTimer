import 'package:flutter/material.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/core/utils/contrast_text_color.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';
import 'package:interval_timer/shared/widgets/countdown_ring.dart';

/// Full-screen dedicated color picker for workout execution phase colors (Work / Rest).
///
/// Features:
/// - Exact miniature smartphone mockup displaying a faithful replica of [TimerExecutionScreen].
/// - Real-time animated countdown ring looping smoothly (00:05 to 00:01).
/// - Non-interactive preview frame encased in an [IgnorePointer].
/// - 10-shade athletic palette swatch grid with instant preview.
/// - One-tap reset and save action buttons.
class PhaseColorPickerScreen extends StatefulWidget {
  const PhaseColorPickerScreen({
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
  State<PhaseColorPickerScreen> createState() => _PhaseColorPickerScreenState();
}

class _PhaseColorPickerScreenState extends State<PhaseColorPickerScreen>
    with SingleTickerProviderStateMixin {
  late Color _selectedColor;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
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
    final theme = Theme.of(context);
    const textColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Exact miniature smartphone mockup with generous breathing room
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                key: const Key('preview_phone_frame'),
                                width: 228,
                                height: 410,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.6),
                                    width: 3.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.22),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(27),
                                  child: IgnorePointer(
                                    key: const Key('preview_phone_ignore_pointer'),
                                    ignoring: true,
                                    child: AnimatedBuilder(
                                      animation: _animController,
                                      builder: (context, _) {
                                        final remainingSeconds =
                                            ((1.0 - _animController.value) * 5)
                                                .ceil()
                                                .clamp(1, 5);
                                        final timeText = '00:0$remainingSeconds';
                                        final ringFraction =
                                            (1.0 - _animController.value)
                                                .clamp(0.0, 1.0);

                                        return Container(
                                          key: const Key(
                                              'preview_phone_screen_canvas'),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _selectedColor,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Camera notch
                                              Center(
                                                child: Container(
                                                  width: 36,
                                                  height: 3.5,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.25),
                                                    borderRadius:
                                                        BorderRadius.circular(2),
                                                  ),
                                                ),
                                              ),

                                              // Top bar (Close, RESTANTE 01:15, Tune)
                                              Row(
                                                key: const Key(
                                                    'preview_phone_top_bar'),
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  _MockupSquareButton(
                                                    icon: Icons.close,
                                                    textColor: textColor,
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        l10n.remainingLabel
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                          color: textColor
                                                              .withValues(
                                                                  alpha: 0.85),
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 1.1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '01:15',
                                                        style: TextStyle(
                                                          color: textColor,
                                                          fontFamily:
                                                              'RobotoMono',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  _MockupSquareButton(
                                                    icon: Icons.tune,
                                                    textColor: textColor,
                                                  ),
                                                ],
                                              ),

                                              // Phase title
                                              Text(
                                                widget.title.toUpperCase(),
                                                key: const Key(
                                                    'preview_phone_phase_title'),
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.2,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),

                                              // Animated Countdown Ring
                                              CountdownRing(
                                                size: 130,
                                                strokeWidth: 8,
                                                remainingFraction: ringFraction,
                                                color: textColor,
                                                child: Center(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      timeText,
                                                      key: const Key(
                                                          'preview_phone_countdown'),
                                                      maxLines: 1,
                                                      softWrap: false,
                                                      style: TextStyle(
                                                        color: textColor,
                                                        fontFamily: 'RobotoMono',
                                                        fontSize: 26,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Next segment banner (ABDOMEN 00:10)
                                              Container(
                                                key: const Key(
                                                    'preview_phone_next_segment'),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: textColor
                                                      .withValues(alpha: 0.14),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          l10n.nextInterval,
                                                          style: TextStyle(
                                                            color: textColor
                                                                .withValues(
                                                                    alpha: 0.75),
                                                            fontSize: 9.5,
                                                          ),
                                                        ),
                                                        Text(
                                                          'ABDOMEN',
                                                          style: TextStyle(
                                                            color: textColor,
                                                            fontSize: 12.5,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      '00:10',
                                                      style: TextStyle(
                                                        color: textColor
                                                            .withValues(
                                                                alpha: 0.85),
                                                        fontFamily:
                                                            'RobotoMono',
                                                        fontSize: 11.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Bottom Controls: [ |<< ] [ || Pausar ] [ >>| ]
                                              Row(
                                                key: const Key(
                                                    'preview_phone_controls'),
                                                children: [
                                                  _MockupSquareButton(
                                                    icon: Icons
                                                        .keyboard_double_arrow_left_rounded,
                                                    textColor: textColor,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Container(
                                                      height: 34,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.pause,
                                                            color: Colors.black,
                                                            size: 16,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            'Pausar',
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  _MockupSquareButton(
                                                    icon: Icons
                                                        .keyboard_double_arrow_right_rounded,
                                                    textColor: textColor,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingMd),

                        // Docked bottom palette: balanced 5x2 grid
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 0; i < 5; i++) ...[
                                  if (i > 0) const SizedBox(width: 10),
                                  _ColorSwatchTile(
                                    color: AppTheme.phaseColorPresets[i],
                                    isSelected: AppTheme.phaseColorPresets[i]
                                            .toARGB32() ==
                                        _selectedColor.toARGB32(),
                                    onTap: () => setState(() =>
                                        _selectedColor =
                                            AppTheme.phaseColorPresets[i]),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 5; i < 10; i++) ...[
                                  if (i > 5) const SizedBox(width: 10),
                                  _ColorSwatchTile(
                                    color: AppTheme.phaseColorPresets[i],
                                    isSelected: AppTheme.phaseColorPresets[i]
                                            .toARGB32() ==
                                        _selectedColor.toARGB32(),
                                    onTap: () => setState(() =>
                                        _selectedColor =
                                            AppTheme.phaseColorPresets[i]),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spacingMd),

                        // Action row: Reset & Save
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                key: const Key('reset_color_button'),
                                onPressed: () {
                                  setState(() =>
                                      _selectedColor = widget.defaultColor);
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MockupSquareButton extends StatelessWidget {
  const _MockupSquareButton({
    required this.icon,
    required this.textColor,
  });

  final IconData icon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: textColor,
        size: 18,
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