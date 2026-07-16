import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';

/// Abstraction over the native share sheet (F16 R7, R17, R19).
abstract class ShareSheetDriver {
  Future<ShareOutcome> shareImage({
    required XFile file,
    Rect? sharePositionOrigin,
    String? text,
  });
}

class PluginShareSheetDriver implements ShareSheetDriver {
  @override
  Future<ShareOutcome> shareImage({
    required XFile file,
    Rect? sharePositionOrigin,
    String? text,
  }) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [file],
          text: text,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
      return switch (result.status) {
        ShareResultStatus.success => ShareOutcome.success,
        ShareResultStatus.dismissed => ShareOutcome.dismissed,
        ShareResultStatus.unavailable => ShareOutcome.unavailable,
      };
    } catch (_) {
      return ShareOutcome.failed;
    }
  }
}

class FakeShareSheetDriver implements ShareSheetDriver {
  FakeShareSheetDriver({
    this.outcome = ShareOutcome.success,
    this.throwOnShare = false,
  });

  ShareOutcome outcome;
  bool throwOnShare;
  int callCount = 0;
  Rect? lastOrigin;
  XFile? lastFile;

  @override
  Future<ShareOutcome> shareImage({
    required XFile file,
    Rect? sharePositionOrigin,
    String? text,
  }) async {
    callCount++;
    lastFile = file;
    lastOrigin = sharePositionOrigin;
    if (throwOnShare) return ShareOutcome.failed;
    return outcome;
  }
}
