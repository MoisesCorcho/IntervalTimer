import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interval_timer/core/l10n/l10n_extension.dart';
import 'package:interval_timer/core/theme/app_theme.dart';
import 'package:interval_timer/features/session_summary/domain/gallery_saver.dart';
import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';
import 'package:interval_timer/features/session_summary/domain/share_image_renderer.dart';
import 'package:interval_timer/features/session_summary/domain/share_sheet_driver.dart';
import 'package:interval_timer/features/session_summary/presentation/session_share_card.dart';
import 'package:interval_timer/shared/widgets/app_primary_button.dart';

/// Full-screen share studio: templates carousel, photo, share & save (F16).
class SessionShareStudioScreen extends StatefulWidget {
  const SessionShareStudioScreen({
    super.key,
    required this.viewData,
    this.shareDriver,
    this.gallerySaver,
    this.imagePicker,
  });

  final SessionCompleteViewData viewData;
  final ShareSheetDriver? shareDriver;
  final GallerySaver? gallerySaver;
  final ImagePicker? imagePicker;

  @override
  State<SessionShareStudioScreen> createState() =>
      _SessionShareStudioScreenState();
}

class _SessionShareStudioScreenState extends State<SessionShareStudioScreen> {
  final _pageController = PageController(viewportFraction: 0.82);
  final _boundaryKey = GlobalKey();
  final _shareButtonKey = GlobalKey();

  late ShareCardData _card;
  int _pageIndex = 0;
  bool _busy = false;

  static const _templates = [
    ShareTemplateStyle.transparent,
    ShareTemplateStyle.solidDark,
    ShareTemplateStyle.solidBrand,
  ];

  ShareSheetDriver get _share =>
      widget.shareDriver ?? PluginShareSheetDriver();
  GallerySaver get _gallery => widget.gallerySaver ?? GalGallerySaver();
  ImagePicker get _picker => widget.imagePicker ?? ImagePicker();

  @override
  void initState() {
    super.initState();
    _card = ShareCardData.fromView(
      widget.viewData,
      template: ShareTemplateStyle.transparent,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() {
      _pageIndex = i;
      _card = _card.copyWith(template: _templates[i]);
    });
  }

  Future<void> _showPhotoSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(context.l10n.sessionSummaryShareTakePhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(context.l10n.sessionSummarySharePickGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              const SizedBox(height: AppTheme.spacingSm),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 88,
      );
      if (file == null || !mounted) return;
      setState(() {
        _card = _card.copyWith(photoPath: file.path);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.sessionSummarySharePhotoFailed)),
      );
    }
  }

  void _clearPhoto() {
    setState(() => _card = _card.copyWith(clearPhoto: true));
  }

  Future<Uint8List?> _capturePng() async {
    final boundary = _boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  Rect? _shareOrigin() {
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _onShare() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final png = await _capturePng();
      if (png == null) throw StateError('capture failed');
      final file = await writeSharePngToTemp(png);
      final outcome = await _share.shareImage(
        file: file,
        sharePositionOrigin: _shareOrigin(),
      );
      if (!mounted) return;
      if (outcome == ShareOutcome.failed ||
          outcome == ShareOutcome.unavailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.sessionSummaryShareFailed)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.sessionSummaryShareFailed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onSaveGallery() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final png = await _capturePng();
      if (png == null) throw StateError('capture failed');
      final ok = await _gallery.savePng(png);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? context.l10n.sessionSummaryShareSavedGallery
                : context.l10n.sessionSummaryShareSaveGalleryFailed,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.sessionSummaryShareSaveGalleryFailed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = _card.photoPath != null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        title: Text(context.l10n.sessionSummaryShareTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _templates.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final style = _templates[index];
                  final isCurrent = index == _pageIndex;
                  final cardData = _card.copyWith(template: style);
                  final card = SessionShareCard(
                    data: cardData,
                    width: 280,
                    height: 400,
                    showAddPhotoPlaceholder:
                        style == ShareTemplateStyle.transparent,
                    onAddPhoto: style == ShareTemplateStyle.transparent
                        ? _showPhotoSourceSheet
                        : null,
                  );

                  Widget content = card;
                  if (isCurrent &&
                      style == ShareTemplateStyle.transparent) {
                    content = Stack(
                      children: [
                        RepaintBoundary(key: _boundaryKey, child: card),
                        if (hasPhoto) ...[
                          Positioned(
                            top: AppTheme.spacingMd,
                            left: AppTheme.spacingMd,
                            child: _RoundIconButton(
                              icon: Icons.delete_outline,
                              onPressed: _clearPhoto,
                            ),
                          ),
                          Positioned(
                            top: AppTheme.spacingMd,
                            right: AppTheme.spacingMd,
                            child: _RoundIconButton(
                              icon: Icons.edit_outlined,
                              onPressed: _showPhotoSourceSheet,
                            ),
                          ),
                        ],
                      ],
                    );
                  } else if (isCurrent) {
                    content = RepaintBoundary(key: _boundaryKey, child: card);
                  }

                  return AnimatedScale(
                    scale: isCurrent ? 1.0 : 0.92,
                    duration: const Duration(milliseconds: 200),
                    child: Center(child: content),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_templates.length, (i) {
                final active = i == _pageIndex;
                return Container(
                  width: active ? 10 : 8,
                  height: active ? 10 : 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
              ),
              child: Column(
                children: [
                  AppPrimaryButton(
                    key: _shareButtonKey,
                    expand: true,
                    onPressed: _busy ? null : _onShare,
                    label: context.l10n.sessionSummaryShare,
                    icon: Icons.ios_share_rounded,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  SizedBox(
                    width: double.infinity,
                    height: AppTheme.buttonMinHeight,
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _onSaveGallery,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.buttonRadius),
                        ),
                      ),
                      icon: const Icon(Icons.download_outlined),
                      label: Text(context.l10n.sessionSummaryShareSaveGallery),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              context.l10n.sessionSummaryShareOfflineHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
      ),
    );
  }
}
