import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class QrPngService {
  const QrPngService();

  Future<Uint8List> generate({
    required GlobalKey repaintKey,
    double pixelRatio = 3,
  }) async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      throw Exception('Unable to find QR card.');
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to generate PNG.');
    }

    return byteData.buffer.asUint8List();
  }

  Future<Map<String, Uint8List>> generateMany({
    required Map<String, GlobalKey> repaintKeys,
    double pixelRatio = 2,
  }) async {
    final files = <String, Uint8List>{};

    for (final entry in repaintKeys.entries) {
      files[entry.key] = await generate(
        repaintKey: entry.value,
        pixelRatio: pixelRatio,
      );
    }

    return files;
  }
}
