import 'dart:io';
import 'package:flutter/material.dart';
import '../models/image_item.dart';

class ImageItemWidget extends StatefulWidget {
  final ImageItem imageItem;
  final Function(ImageItem) onUpdate;
  final VoidCallback onDelete;

  const ImageItemWidget({
    Key? key,
    required this.imageItem,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ImageItemWidget> createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  late ImageItem _imageItem;
  bool _isDragging = false;
  bool _isResizing = false;
  Offset _startDragOffset = Offset.zero;
  Offset _lastPosition = Offset.zero;
  Size _lastSize = Size.zero;
  double _lastRotation = 0.0;
  double _lastScale = 1.0;

  @override
  void initState() {
    super.initState();
    _imageItem = widget.imageItem;
    _lastPosition = Offset(_imageItem.x, _imageItem.y);
    _lastSize = Size(_imageItem.width, _imageItem.height);
    _lastRotation = _imageItem.rotation;
    _lastScale = _imageItem.scale;
  }

  @override
  void didUpdateWidget(ImageItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageItem != widget.imageItem) {
      _imageItem = widget.imageItem;
      _lastPosition = Offset(_imageItem.x, _imageItem.y);
      _lastSize = Size(_imageItem.width, _imageItem.height);
      _lastRotation = _imageItem.rotation;
      _lastScale = _imageItem.scale;
    }
  }

  void _updateImageItem() {
    final updatedImageItem = _imageItem.copyWith(
      x: _lastPosition.dx,
      y: _lastPosition.dy,
      width: _lastSize.width,
      height: _lastSize.height,
      rotation: _lastRotation,
      scale: _lastScale,
    );
    widget.onUpdate(updatedImageItem);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _imageItem.x,
      top: _imageItem.y,
      child: Transform.rotate(
        angle: _imageItem.rotation,
        child: Transform.scale(
          scale: _imageItem.scale,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
                _startDragOffset = details.localPosition;
              });
            },
            onPanUpdate: (details) {
              if (_isDragging) {
                setState(() {
                  final dx = details.globalPosition.dx - _startDragOffset.dx;
                  final dy = details.globalPosition.dy - _startDragOffset.dy;
                  _lastPosition = Offset(dx, dy);
                  _imageItem = _imageItem.copyWith(x: dx, y: dy);
                });
              }
            },
            onPanEnd: (details) {
              setState(() {
                _isDragging = false;
                _updateImageItem();
              });
            },
            onScaleStart: (details) {
              if (_isResizing) return;
              _lastSize = Size(_imageItem.width, _imageItem.height);
              _lastRotation = _imageItem.rotation;
              _lastScale = _imageItem.scale;
            },
            onScaleUpdate: (details) {
              if (_isDragging) return;
              setState(() {
                _isResizing = true;
                _lastScale = _imageItem.scale * details.scale;
                _lastRotation = _imageItem.rotation + details.rotation;
                
                // Update size based on scale
                final newWidth = _imageItem.width * details.scale;
                final newHeight = _imageItem.height * details.scale;
                
                _imageItem = _imageItem.copyWith(
                  scale: _lastScale,
                  rotation: _lastRotation,
                  width: newWidth,
                  height: newHeight,
                );
              });
            },
            onScaleEnd: (details) {
              setState(() {
                _isResizing = false;
                _updateImageItem();
              });
            },
            child: Stack(
              children: [
                Container(
                  width: _imageItem.width,
                  height: _imageItem.height,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Image.file(
                    File(_imageItem.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete image',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
