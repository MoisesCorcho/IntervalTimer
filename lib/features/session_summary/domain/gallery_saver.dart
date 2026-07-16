import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Saves a PNG to the device gallery (F16 share studio).
abstract class GallerySaver {
  Future<bool> savePng(Uint8List bytes, {String name = 'session_summary'});
}

class GalGallerySaver implements GallerySaver {
  @override
  Future<bool> savePng(Uint8List bytes, {String name = 'session_summary'}) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) return false;
      }
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      await Gal.putImage(file.path);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class FakeGallerySaver implements GallerySaver {
  bool shouldSucceed = true;
  int callCount = 0;
  Uint8List? lastBytes;

  @override
  Future<bool> savePng(Uint8List bytes, {String name = 'session_summary'}) async {
    callCount++;
    lastBytes = bytes;
    return shouldSucceed;
  }
}
