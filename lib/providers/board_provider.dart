import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../models/sticky_note.dart';
import '../models/drawing.dart';
import '../models/image_item.dart';
import '../services/storage_service.dart';

// Provider for all boards
final boardsProvider = StateNotifierProvider<BoardsNotifier, List<Board>>((ref) {
  return BoardsNotifier();
});

class BoardsNotifier extends StateNotifier<List<Board>> {
  BoardsNotifier() : super([]) {
    _loadBoards();
  }

  void _loadBoards() {
    state = StorageService.getAllBoards();
  }

  Future<void> addBoard(String name) async {
    final newBoard = Board(name: name);
    await StorageService.saveBoard(newBoard);
    state = [...state, newBoard];
  }

  Future<void> updateBoard(Board board) async {
    await StorageService.saveBoard(board);
    state = [
      for (final item in state)
        if (item.id == board.id) board else item
    ];
  }

  Future<void> deleteBoard(String boardId) async {
    await StorageService.deleteBoard(boardId);
    state = state.where((board) => board.id != boardId).toList();
  }

  Future<void> copyBoard(String boardId, String newName) async {
    final originalBoard = state.firstWhere((board) => board.id == boardId);
    final newBoard = originalBoard.copyBoard(newName: newName);
    await StorageService.saveBoard(newBoard);
    state = [...state, newBoard];
  }
}

// Provider for the currently selected board
final selectedBoardIdProvider = StateProvider<String?>((ref) => null);

// Provider that combines the selected board ID with the boards list
final selectedBoardProvider = Provider<Board?>((ref) {
  final selectedBoardId = ref.watch(selectedBoardIdProvider);
  final boards = ref.watch(boardsProvider);
  
  if (selectedBoardId == null) return null;
  
  try {
    return boards.firstWhere(
      (board) => board.id == selectedBoardId,
    );
  } catch (e) {
    // If board not found, return null
    return null;
  }
});

// Providers for board items
final stickyNotesProvider = Provider<List<StickyNote>>((ref) {
  final selectedBoard = ref.watch(selectedBoardProvider);
  return selectedBoard?.stickyNotes ?? [];
});

final drawingsProvider = Provider<List<Drawing>>((ref) {
  final selectedBoard = ref.watch(selectedBoardProvider);
  return selectedBoard?.drawings ?? [];
});

final imagesProvider = Provider<List<ImageItem>>((ref) {
  final selectedBoard = ref.watch(selectedBoardProvider);
  return selectedBoard?.images ?? [];
});
