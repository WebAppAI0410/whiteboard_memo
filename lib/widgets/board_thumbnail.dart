import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/board.dart';
import '../services/thumbnail_service.dart';

class BoardThumbnail extends StatefulWidget {
  final Board board;
  
  const BoardThumbnail({
    Key? key,
    required this.board,
  }) : super(key: key);
  
  @override
  State<BoardThumbnail> createState() => _BoardThumbnailState();
}

class _BoardThumbnailState extends State<BoardThumbnail> {
  Uint8List? _thumbnailData;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }
  
  @override
  void didUpdateWidget(BoardThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.board != widget.board) {
      _generateThumbnail();
    }
  }
  
  Future<void> _generateThumbnail() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final thumbnail = await ThumbnailService.generateBoardThumbnail(widget.board);
      
      if (mounted) {
        setState(() {
          _thumbnailData = thumbnail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: 80,
        height: 60,
        color: Colors.grey[200],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    
    if (_thumbnailData != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          _thumbnailData!,
          width: 80,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    }
    
    // Fallback
    return Container(
      width: 80,
      height: 60,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 20,
      ),
    );
  }
}
