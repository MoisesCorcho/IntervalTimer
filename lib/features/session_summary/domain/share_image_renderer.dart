import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:interval_timer/features/session_summary/domain/session_complete_models.dart';

/// Renders share card bytes offline (F16 R6, R8, R16).
abstract class ShareImageRenderer {
  Future<Uint8List> renderPng(
    ShareCardData data, {
    double pixelRatio = 3,
  });
}

/// Captures a [RepaintBoundary] already in the tree (preview/offstage card).
class BoundaryShareImageRenderer implements ShareImageRenderer {
  BoundaryShareImageRenderer(this.boundaryKey);

  final GlobalKey boundaryKey;

  @override
  Future<Uint8List> renderPng(
    ShareCardData data, {
    double pixelRatio = 3,
  }) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('Share card RepaintBoundary not mounted');
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode share card PNG');
    }
    return byteData.buffer.asUint8List();
  }
}

class FakeShareImageRenderer implements ShareImageRenderer {
  FakeShareImageRenderer({
    this.bytes = const [1, 2, 3],
    this.shouldFail = false,
  });

  final List<int> bytes;
  bool shouldFail;
  int callCount = 0;
  ShareCardData? lastData;

  @override
  Future<Uint8List> renderPng(
    ShareCardData data, {
    double pixelRatio = 3,
  }) async {
    callCount++;
    lastData = data;
    if (shouldFail) {
      throw StateError('fake render failure');
    }
    return Uint8List.fromList(bytes);
  }
}

/// Writes PNG bytes to a temp file for [ShareSheetDriver].
Future<XFile> writeSharePngToTemp(Uint8List pngBytes) async {
  final dir = await getTemporaryDirectory();
  final path =
      '${dir.path}/session_summary_${DateTime.now().millisecondsSinceEpoch}.png';
  final file = File(path);
  await file.writeAsBytes(pngBytes, flush: true);
  return XFile(path, mimeType: 'image/png');
}
