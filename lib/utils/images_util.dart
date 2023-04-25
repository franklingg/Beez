import 'dart:ui';

import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:google_fonts/google_fonts.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset(size.width, 0), Paint());
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    return false;
  }
}

class ImagesUtil {
  static Future<ui.Image> getImage(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  static Future<MapEntry<EventModel, Uint8List>> getMarkerBytesEvent(
      String path, int width, EventModel event) async {
    PictureRecorder recorder = PictureRecorder();
    Canvas c = Canvas(recorder);

    ui.Image image = await getImage(path, width);
    ImagePainter ip = ImagePainter(image);

    TextSpan span = TextSpan(
        style: TextStyle(
            fontFamily: GoogleFonts.notoSans().fontFamily,
            color: AppColors.darkYellow,
            fontSize: 24,
            fontWeight: FontWeight.w700),
        text: event.name);

    TextPainter tp = TextPainter(
      maxLines: 2,
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // tp.layout();
    tp.layout(maxWidth: 150);
    ip.paint(c, tp.size);
    tp.paint(
        c,
        Offset(
            ip.image.width.toDouble() +
                tp.width -
                (tp.size.width == 150 ? 15 : 0),
            ip.image.height - (tp.size.width == 150 ? 80 : 60)));

    Picture p = recorder.endRecording();
    ByteData? pngBytes = await (await p.toImage(
            ip.image.width + tp.width.toInt() * 2, ip.image.height))
        .toByteData(format: ImageByteFormat.png);

    return MapEntry(event, Uint8List.view(pngBytes!.buffer));
  }
}
