import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drawing.dart';
import '../providers/drawing_provider.dart';
import '../providers/board_provider.dart';

class DrawingCanvas extends ConsumerStatefulWidget {
  final String boardId;

  const DrawingCanvas({
    Key? key,
    required this.boardId,
  }) : super(key: key);

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  List<Offset> _points = [];
  Offset? _startPoint;
  Offset? _endPoint;

  @override
  Widget build(BuildContext context) {
    final drawingTool = ref.watch(drawingToolProvider);
    final drawingColor = ref.watch(drawingColorProvider);
    final strokeWidth = ref.watch(strokeWidthProvider);
    final currentDrawing = ref.watch(currentDrawingProvider);

    return GestureDetector(
      onPanStart: (details) {
        if (drawingTool == DrawingTool.none) return;

        final localPosition = details.localPosition;
        
        setState(() {
          _startPoint = localPosition;
          _endPoint = localPosition;
          _points = [localPosition];
        });

        // Create a new drawing
        final newDrawing = Drawing(
          color: drawingColor,
          strokeWidth: strokeWidth,
          type: _getDrawingType(drawingTool),
          points: [localPosition],
          startPoint: localPosition,
          endPoint: localPosition,
        );

        ref.read(currentDrawingProvider.notifier).state = newDrawing;
      },
      onPanUpdate: (details) {
        if (drawingTool == DrawingTool.none || currentDrawing == null) return;

        final localPosition = details.localPosition;
        
        setState(() {
          _endPoint = localPosition;
          
          if (drawingTool == DrawingTool.pen || drawingTool == DrawingTool.eraser) {
            _points.add(localPosition);
          }
        });

        // Update the current drawing
        final updatedDrawing = currentDrawing.copyWith(
          points: drawingTool == DrawingTool.pen || drawingTool == DrawingTool.eraser
              ? [..._points]
              : currentDrawing.points,
          endPoint: localPosition,
        );

        ref.read(currentDrawingProvider.notifier).state = updatedDrawing;
      },
      onPanEnd: (details) {
        if (drawingTool == DrawingTool.none || currentDrawing == null) return;

        // Finalize the drawing
        final finalDrawing = currentDrawing.copyWith(
          points: _points,
          startPoint: _startPoint,
          endPoint: _endPoint,
        );

        // Add to history and board
        ref.read(drawingHistoryProvider.notifier).addDrawing(finalDrawing);
        
        // Reset current drawing
        ref.read(currentDrawingProvider.notifier).state = null;
        
        setState(() {
          _points = [];
          _startPoint = null;
          _endPoint = null;
        });
      },
      child: CustomPaint(
        painter: _DrawingPainter(
          points: _points,
          startPoint: _startPoint,
          endPoint: _endPoint,
          drawingTool: drawingTool,
          color: drawingTool == DrawingTool.eraser ? Colors.white : drawingColor,
          strokeWidth: strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }

  DrawingType _getDrawingType(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.pen:
      case DrawingTool.eraser:
        return DrawingType.freehand;
      case DrawingTool.line:
        return DrawingType.line;
      case DrawingTool.rectangle:
        return DrawingType.rectangle;
      case DrawingTool.circle:
        return DrawingType.circle;
      default:
        return DrawingType.freehand;
    }
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset> points;
  final Offset? startPoint;
  final Offset? endPoint;
  final DrawingTool drawingTool;
  final Color color;
  final double strokeWidth;

  _DrawingPainter({
    required this.points,
    required this.startPoint,
    required this.endPoint,
    required this.drawingTool,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (drawingTool) {
      case DrawingTool.pen:
      case DrawingTool.eraser:
        if (points.length < 2) return;
        
        final path = Path();
        path.moveTo(points.first.dx, points.first.dy);
        
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        
        canvas.drawPath(path, paint);
        break;
        
      case DrawingTool.line:
        if (startPoint == null || endPoint == null) return;
        
        canvas.drawLine(
          startPoint!,
          endPoint!,
          paint,
        );
        break;
        
      case DrawingTool.rectangle:
        if (startPoint == null || endPoint == null) return;
        
        final rect = Rect.fromPoints(
          startPoint!,
          endPoint!,
        );
        
        canvas.drawRect(rect, paint);
        break;
        
      case DrawingTool.circle:
        if (startPoint == null || endPoint == null) return;
        
        final rect = Rect.fromPoints(
          startPoint!,
          endPoint!,
        );
        
        canvas.drawOval(rect, paint);
        break;
        
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint ||
        oldDelegate.drawingTool != drawingTool ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
