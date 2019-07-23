import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<dynamic> loadNetworkImage(String url, { int width: -1, int height: -1 }) async {
  final NetworkImage image = NetworkImage(url);
  final NetworkImage val = await image.obtainKey(ImageConfiguration());
  debugPrint('image $image');
  debugPrint('val $val');
  final ImageStreamCompleter load = image.load(val);
  final completer = Completer();

  load.addListener(ImageStreamListener((ImageInfo info, bool syncCall) async {
    final res = await getBytesFromCanvas(info.image, width: width, height: height);
    completer.complete(BitmapDescriptor.fromBytes(res));
  }));

  return completer.future;
}

Future<Uint8List> getBytesFromCanvas(dynamic inputImg, { int width: -1, int height: -1 }) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  
  if (width == -1 && height == -1) {
    width = inputImg.width;
    height = inputImg.height;
  } else if (width == -1) {
    double ratio = inputImg.width / inputImg.height;
    width = (height * ratio).toInt();
  } else {
    double ratio = inputImg.height / inputImg.width;
    height = (width * ratio).toInt();
  }

  final Rect inRect = Offset.zero & Size(inputImg.width.toDouble(), inputImg.height.toDouble()); 
  final Rect outRect = Offset.zero & Size(width.toDouble(), height.toDouble());
  
  canvas.drawImageRect(inputImg, inRect, outRect, Paint());
  
  final img = await pictureRecorder.endRecording().toImage(width, height);
  final data = await img.toByteData(format: ImageByteFormat.png);
  return data.buffer.asUint8List();
}