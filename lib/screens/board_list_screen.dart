import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board.dart';
import '../providers/board_provider.dart';
import '../providers/premium_provider.dart';
import 'board_edit_screen.dart';
import 'settings_screen.dart';
import 'premium_upgrade_screen.dart';
import '../widgets/board_thumbnail.dart';

class BoardListScreen extends ConsumerWidget {
  const BoardListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(boardsProvider);
    final maxBoards = ref.watch(maxBoardsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WhiteboardMemo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: boards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.dashboard_customize, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No whiteboards yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first whiteboard to get started',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Whiteboard'),
                    onPressed: () {
                      print('Button pressed directly');
                      // Create a board directly without dialog for testing
                      ref.read(boardsProvider.notifier).addBoard('New Whiteboard');
                    },
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: boards.length,
              itemBuilder: (context, index) {
                final board = boards[index];
                return _BoardCard(board: board);
              },
            ),
      floatingActionButton: boards.length < maxBoards
          ? FloatingActionButton(
              onPressed: () => _showCreateBoardDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isPremium
                          ? 'You have reached the maximum number of boards'
                          : 'Upgrade to premium for unlimited boards',
                    ),
                    action: isPremium
                        ? null
                        : SnackBarAction(
                            label: 'Upgrade',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PremiumUpgradeScreen()),
                              );
                            },
                          ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  void _showCreateBoardDialog(BuildContext context, WidgetRef ref) {
    print('_showCreateBoardDialog called');
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Whiteboard'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Board Name',
            hintText: 'Enter a name for your whiteboard',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                ref.read(boardsProvider.notifier).addBoard(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _BoardCard extends ConsumerWidget {
  final Board board;

  const _BoardCard({required this.board});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          ref.read(selectedBoardIdProvider.notifier).state = board.id;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BoardEditScreen(),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    if (board.stickyNotes.isNotEmpty || board.drawings.isNotEmpty || board.images.isNotEmpty)
                      const Center(
                        child: Icon(
                          Icons.dashboard_customize,
                          size: 48,
                          color: Colors.grey,
                        ),
                      )
                    else
                      const Center(
                        child: Icon(
                          Icons.dashboard_customize,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    Container(
                      width: 80,
                      height: 60,
                      child: BoardThumbnail(board: board),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    board.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last edited: ${_formatDate(board.updatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _showCopyBoardDialog(context, ref),
                    tooltip: 'Copy board',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _showDeleteBoardDialog(context, ref),
                    tooltip: 'Delete board',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCopyBoardDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController(text: '${board.name} (Copy)');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copy Whiteboard'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New Board Name',
            hintText: 'Enter a name for the copied whiteboard',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                ref.read(boardsProvider.notifier).copyBoard(board.id, name);
                Navigator.pop(context);
              }
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showDeleteBoardDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Whiteboard'),
        content: Text('Are you sure you want to delete "${board.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(boardsProvider.notifier).deleteBoard(board.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
