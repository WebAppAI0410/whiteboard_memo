import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/board.dart';
import '../models/drawing.dart';
import '../models/sticky_note.dart';
import '../models/image_item.dart';

class ThumbnailService {
  // Generate a thumbnail preview for a board
  static Future<Uint8List?> generateBoardThumbnail(Board board) async {
    // Create a small canvas to render the board
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(150, 100);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Draw background
    canvas.drawRect(Offset.zero & size, paint);
    
    // Draw stick notes (simplified)
    for (final note in board.stickyNotes) {
      final noteSize = Size(20, 20);
      final noteOffset = _scaleToThumbnail(
        Offset(note.x, note.y), 
        size, 
        originalSize: const Size(1000, 800),
      );
      
      final notePaint = Paint()
        ..color = note.color
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        noteOffset & noteSize, 
        notePaint,
      );
    }
    
    // Draw drawings (simplified)
    for (final drawing in board.drawings) {
      if (drawing.points.isEmpty) continue;
      
      final drawingPaint = Paint()
        ..color = drawing.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      // For freehand, draw a simple path
      if (drawing.type == DrawingType.freehand) {
        final path = Path();
        final first = _scaleToThumbnail(
          drawing.points.first, 
          size,
          originalSize: const Size(1000, 800),
        );
        path.moveTo(first.dx, first.dy);
        
        for (int i = 1; i < drawing.points.length; i += 3) {
          final point = _scaleToThumbnail(
            drawing.points[i], 
            size,
            originalSize: const Size(1000, 800),
          );
          path.lineTo(point.dx, point.dy);
        }
        
        canvas.drawPath(path, drawingPaint);
      } 
      // For shapes, draw simplified versions
      else if (drawing.startPoint != null && drawing.endPoint != null) {
        final start = _scaleToThumbnail(
          drawing.startPoint!, 
          size,
          originalSize: const Size(1000, 800),
        );
        final end = _scaleToThumbnail(
          drawing.endPoint!, 
          size,
          originalSize: const Size(1000, 800),
        );
        
        if (drawing.type == DrawingType.line) {
          canvas.drawLine(start, end, drawingPaint);
        } else if (drawing.type == DrawingType.rectangle) {
          canvas.drawRect(Rect.fromPoints(start, end), drawingPaint);
        } else if (drawing.type == DrawingType.circle) {
          canvas.drawOval(Rect.fromPoints(start, end), drawingPaint);
        }
      }
    }
    
    // Draw images (just outlines)
    for (final image in board.images) {
      final imageOffset = _scaleToThumbnail(
        Offset(image.x, image.y), 
        size,
        originalSize: const Size(1000, 800),
      );
      final imageSize = Size(15, 15);
      
      final imagePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      canvas.drawRect(
        imageOffset & imageSize, 
        imagePaint,
      );
    }
    
    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }
  
  // Helper to scale coordinates from board size to thumbnail size
  static Offset _scaleToThumbnail(
    Offset original, 
    Size thumbnailSize, 
    {required Size originalSize}
  ) {
    return Offset(
      (original.dx / originalSize.width) * thumbnailSize.width,
      (original.dy / originalSize.height) * thumbnailSize.height,
    );
  }
}
