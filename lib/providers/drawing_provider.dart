import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drawing.dart';
import 'board_provider.dart';

// Current drawing tool
enum DrawingTool {
  none,
  pen,
  eraser,
  line,
  rectangle,
  circle,
}

// Provider for the current drawing tool
final drawingToolProvider = StateProvider<DrawingTool>((ref) => DrawingTool.none);

// Provider for the current drawing color
final drawingColorProvider = StateProvider<Color>((ref) => Colors.black);

// Provider for the current stroke width
final strokeWidthProvider = StateProvider<double>((ref) => 3.0);

// Provider for the current drawing
final currentDrawingProvider = StateProvider<Drawing?>((ref) => null);

// Provider for the drawing history (for undo/redo)
final drawingHistoryProvider = StateNotifierProvider<DrawingHistoryNotifier, DrawingHistory>((ref) {
  return DrawingHistoryNotifier(ref);
});

class DrawingHistory {
  final List<Drawing> undoStack;
  final List<Drawing> redoStack;

  DrawingHistory({
    this.undoStack = const [],
    this.redoStack = const [],
  });

  DrawingHistory copyWith({
    List<Drawing>? undoStack,
    List<Drawing>? redoStack,
  }) {
    return DrawingHistory(
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

class DrawingHistoryNotifier extends StateNotifier<DrawingHistory> {
  final Ref _ref;

  DrawingHistoryNotifier(this._ref) : super(DrawingHistory());

  void addDrawing(Drawing drawing) {
    final selectedBoard = _ref.read(selectedBoardProvider);
    if (selectedBoard == null) return;

    // Add to board
    selectedBoard.addDrawing(drawing);
    _ref.read(boardsProvider.notifier).updateBoard(selectedBoard);

    // Add to history
    state = state.copyWith(
      undoStack: [...state.undoStack, drawing],
      redoStack: [],
    );
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    
    final selectedBoard = _ref.read(selectedBoardProvider);
    if (selectedBoard == null) return;

    final lastDrawing = state.undoStack.last;
    final newUndoStack = List<Drawing>.from(state.undoStack)..removeLast();
    
    // Remove from board
    selectedBoard.removeDrawing(lastDrawing.id);
    _ref.read(boardsProvider.notifier).updateBoard(selectedBoard);

    // Update history
    state = state.copyWith(
      undoStack: newUndoStack,
      redoStack: [...state.redoStack, lastDrawing],
    );
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    
    final selectedBoard = _ref.read(selectedBoardProvider);
    if (selectedBoard == null) return;

    final lastRedoDrawing = state.redoStack.last;
    final newRedoStack = List<Drawing>.from(state.redoStack)..removeLast();
    
    // Add back to board
    selectedBoard.addDrawing(lastRedoDrawing);
    _ref.read(boardsProvider.notifier).updateBoard(selectedBoard);

    // Update history
    state = state.copyWith(
      undoStack: [...state.undoStack, lastRedoDrawing],
      redoStack: newRedoStack,
    );
  }

  void clearHistory() {
    state = DrawingHistory();
  }
}
