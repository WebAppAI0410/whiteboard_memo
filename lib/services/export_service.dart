import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  // Capture a widget as an image
  static Future<ui.Image> captureWidget(GlobalKey key) async {
    final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    return image;
  }

  // Save image to gallery
  static Future<String?> saveToGallery(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    final result = await ImageGallerySaver.saveImage(
      buffer,
      quality: 100,
      name: "whiteboard_memo_${DateTime.now().millisecondsSinceEpoch}",
    );
    
    if (result['isSuccess']) {
      return result['filePath'];
    }
    return null;
  }

  // Share image
  static Future<void> shareImage(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/whiteboard_memo_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(buffer);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Shared from WhiteboardMemo',
    );
  }

  // Export as PNG and return the file path
  static Future<String> exportAsPng(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/whiteboard_memo_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(buffer);
    
    return filePath;
  }
}
