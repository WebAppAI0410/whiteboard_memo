import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;

import '../models/board.dart';
import '../models/sticky_note.dart';
import '../models/drawing.dart';
import '../models/image_item.dart';
import '../providers/board_provider.dart';
import '../providers/drawing_provider.dart';
import '../providers/premium_provider.dart';
import '../services/export_service.dart';
import '../widgets/sticky_note_widget.dart';
import '../widgets/image_widget.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_toolbar.dart';

class BoardEditScreen extends ConsumerStatefulWidget {
  const BoardEditScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BoardEditScreen> createState() => _BoardEditScreenState();
}

class _BoardEditScreenState extends ConsumerState<BoardEditScreen> {
  final GlobalKey _boardKey = GlobalKey();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final selectedBoard = ref.watch(selectedBoardProvider);
    final drawingTool = ref.watch(drawingToolProvider);
    
    if (selectedBoard == null) {
      return const Scaffold(
        body: Center(
          child: Text('No board selected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedBoard.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _pickImage,
            tooltip: 'Add Image',
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: _addStickyNote,
            tooltip: 'Add Sticky Note',
          ),
          IconButton(
            icon: const Icon(Icons.square),
            onPressed: _addSquareStickyNote,
            tooltip: 'Add Square Note',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportAndShare,
            tooltip: 'Export & Share',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Board background
          Container(
            color: Colors.grey[100],
          ),
          
          // Board content with RepaintBoundary for export
          RepaintBoundary(
            key: _boardKey,
            child: Stack(
              children: [
                // Sticky notes
                ..._buildStickyNotes(),
                
                // Images
                ..._buildImages(),
                
                // Drawings
                ..._buildDrawings(),
                
                // Drawing canvas (only visible when drawing tool is active)
                if (drawingTool != DrawingTool.none)
                  DrawingCanvas(
                    boardId: selectedBoard.id,
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DrawingToolbar(),
    );
  }

  List<Widget> _buildStickyNotes() {
    final stickyNotes = ref.watch(stickyNotesProvider);
    return stickyNotes.map((note) => StickyNoteWidget(
      key: ValueKey(note.id),
      note: note,
      onUpdate: (updatedNote) {
        final selectedBoard = ref.read(selectedBoardProvider);
        if (selectedBoard != null) {
          selectedBoard.updateStickyNote(updatedNote);
          ref.read(boardsProvider.notifier).updateBoard(selectedBoard);
        }
      },
      onDelete: () {
        final selectedBoard = ref.read(selectedBoardProvider);
        if (selectedBoard != null) {
          selectedBoard.removeStickyNote(note.id);
          ref.read(boardsProvider.notifier).updateBoard(selectedBoard);
        }
      },
    )).toList();
  }

  List<Widget> _buildImages() {
    final images = ref.watch(imagesProvider);
    return images.map((image) => ImageItemWidget(
      key: ValueKey(image.id),
      imageItem: image,
      onUpdate: (updatedImage) {
        final selectedBoard = ref.read(selectedBoardProvider);
        if (selectedBoard != null) {
          selectedBoard.updateImage(updatedImage);
          ref.read(boardsProvider.notifier).updateBoard(selectedBoard);
        }
      },
      onDelete: () {
        final selectedBoard = ref.read(selectedBoardProvider);
        if (selectedBoard != null) {
          selectedBoard.removeImage(image.id);
          ref.read(boardsProvider.notifier).updateBoard(selectedBoard);
        }
      },
    )).toList();
  }

  List<Widget> _buildDrawings() {
    final drawings = ref.watch(drawingsProvider);
    return [
      CustomPaint(
        painter: DrawingsPainter(drawings: drawings),
        size: Size.infinite,
      ),
    ];
  }

  void _addStickyNote() {
    final selectedBoard = ref.read(selectedBoardProvider);
    if (selectedBoard != null) {
      final note = StickyNote(
        text: '',
        color: Colors.yellow,
        x: 100,
        y: 100,
        shape: StickyNoteShape.rectangle,
      );
      selectedBoard.addStickyNote(note);
      ref.read(boardsProvider.notifier).updateBoard(selectedBoard);
    }
  }

  void _addSquareStickyNote() {
    final selectedBoard = ref.read(selectedBoardProvider);
    if (selectedBoard != null) {
      final note = StickyNote(
        text: '',
        color: Colors.yellow,
        x: 100,
        y: 100,
        width: 150,
        height: 150,
        shape: StickyNoteShape.square,
      );
      selectedBoard.addStickyNote(note);
      ref.read(boardsProvider.notifier).updateBoard(selectedBoard);
    }
  }

  Future<void> _pickImage() async {
    final selectedBoard = ref.read(selectedBoardProvider);
    if (selectedBoard == null) return;

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        final imageItem = ImageItem(
          imagePath: pickedFile.path,
          x: 100,
          y: 100,
        );
        selectedBoard.addImage(imageItem);
        ref.read(boardsProvider.notifier).updateBoard(selectedBoard);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _exportAndShare() async {
    try {
      // Check if premium feature is available
      final isPremiumExport = ref.read(premiumFeatureProvider(PremiumFeature.highResolutionExport));
      
      // Capture the board as an image
      final boundary = _boardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(
        pixelRatio: isPremiumExport ? 3.0 : 1.0,
      );
      
      // Show export options
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Save to Gallery'),
                onTap: () => Navigator.pop(context, 'save'),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () => Navigator.pop(context, 'share'),
              ),
            ],
          ),
        ),
      );
      
      if (action == null) return;
      
      if (action == 'save') {
        final path = await ExportService.saveToGallery(image);
        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to gallery')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save image')),
          );
        }
      } else if (action == 'share') {
        await ExportService.shareImage(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting board: $e')),
      );
    }
  }
}

class DrawingsPainter extends CustomPainter {
  final List<Drawing> drawings;

  DrawingsPainter({required this.drawings});

  @override
  void paint(Canvas canvas, Size size) {
    for (final drawing in drawings) {
      final paint = Paint()
        ..color = drawing.color
        ..strokeWidth = drawing.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      switch (drawing.type) {
        case DrawingType.freehand:
          if (drawing.points.length < 2) continue;
          
          final path = Path();
          path.moveTo(drawing.points.first.dx, drawing.points.first.dy);
          
          for (int i = 1; i < drawing.points.length; i++) {
            path.lineTo(drawing.points[i].dx, drawing.points[i].dy);
          }
          
          canvas.drawPath(path, paint);
          break;
          
        case DrawingType.line:
          if (drawing.startPoint == null || drawing.endPoint == null) continue;
          
          canvas.drawLine(
            drawing.startPoint!,
            drawing.endPoint!,
            paint,
          );
          break;
          
        case DrawingType.rectangle:
          if (drawing.startPoint == null || drawing.endPoint == null) continue;
          
          final rect = Rect.fromPoints(
            drawing.startPoint!,
            drawing.endPoint!,
          );
          
          canvas.drawRect(rect, paint);
          break;
          
        case DrawingType.circle:
          if (drawing.startPoint == null || drawing.endPoint == null) continue;
          
          final rect = Rect.fromPoints(
            drawing.startPoint!,
            drawing.endPoint!,
          );
          
          canvas.drawOval(rect, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingsPainter oldDelegate) {
    return oldDelegate.drawings != drawings;
  }
}
