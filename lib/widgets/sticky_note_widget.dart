import 'package:flutter/material.dart';
import '../models/sticky_note.dart';

class StickyNoteWidget extends StatefulWidget {
  final StickyNote note;
  final Function(StickyNote) onUpdate;
  final VoidCallback onDelete;

  const StickyNoteWidget({
    Key? key,
    required this.note,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<StickyNoteWidget> createState() => _StickyNoteWidgetState();
}

class _StickyNoteWidgetState extends State<StickyNoteWidget> {
  late StickyNote _note;
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;
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
    _note = widget.note;
    _textController.text = _note.text;
    _lastPosition = Offset(_note.x, _note.y);
    _lastSize = Size(_note.width, _note.height);
    _lastRotation = _note.rotation;
    _lastScale = _note.scale;
  }

  @override
  void didUpdateWidget(StickyNoteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note != widget.note) {
      _note = widget.note;
      if (!_isEditing) {
        _textController.text = _note.text;
      }
      _lastPosition = Offset(_note.x, _note.y);
      _lastSize = Size(_note.width, _note.height);
      _lastRotation = _note.rotation;
      _lastScale = _note.scale;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateNote() {
    final updatedNote = _note.copyWith(
      text: _textController.text,
      x: _lastPosition.dx,
      y: _lastPosition.dy,
      width: _lastSize.width,
      height: _lastSize.height,
      rotation: _lastRotation,
      scale: _lastScale,
    );
    widget.onUpdate(updatedNote);
  }

  void _showColorPicker() {
    final colors = [
      Colors.yellow,
      Colors.orange,
      Colors.pink,
      Colors.red,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.teal,
      Colors.white,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _note = _note.copyWith(color: color);
                });
                _updateNote();
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _note.color.value == color.value
                    ? const Icon(Icons.check, color: Colors.black)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _note.x,
      top: _note.y,
      child: Transform.rotate(
        angle: _note.rotation,
        child: Transform.scale(
          scale: _note.scale,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isEditing = true;
              });
            },
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
                  _note = _note.copyWith(x: dx, y: dy);
                });
              }
            },
            onPanEnd: (details) {
              setState(() {
                _isDragging = false;
                _updateNote();
              });
            },
            onScaleStart: (details) {
              if (_isResizing) return;
              _lastSize = Size(_note.width, _note.height);
              _lastRotation = _note.rotation;
              _lastScale = _note.scale;
            },
            onScaleUpdate: (details) {
              if (_isDragging || _isEditing) return;
              setState(() {
                _isResizing = true;
                _lastScale = _note.scale * details.scale;
                _lastRotation = _note.rotation + details.rotation;
                _note = _note.copyWith(
                  scale: _lastScale,
                  rotation: _lastRotation,
                );
              });
            },
            onScaleEnd: (details) {
              setState(() {
                _isResizing = false;
                _updateNote();
              });
            },
            child: Container(
              width: _note.width,
              height: _note.shape == StickyNoteShape.square ? _note.width : _note.height,
              decoration: BoxDecoration(
                color: _note.color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        autofocus: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter text...',
                        ),
                        onEditingComplete: () {
                          setState(() {
                            _isEditing = false;
                            _updateNote();
                          });
                        },
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _note.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.color_lens, size: 20),
                          onPressed: _showColorPicker,
                          tooltip: 'Change color',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: widget.onDelete,
                          tooltip: 'Delete note',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
