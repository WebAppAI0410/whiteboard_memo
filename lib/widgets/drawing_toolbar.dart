import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drawing_provider.dart';

class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingTool = ref.watch(drawingToolProvider);
    final drawingColor = ref.watch(drawingColorProvider);
    final strokeWidth = ref.watch(strokeWidthProvider);
    final drawingHistory = ref.watch(drawingHistoryProvider);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drawing tools
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildToolButton(
                  context,
                  ref,
                  icon: Icons.touch_app,
                  tooltip: 'Select',
                  tool: DrawingTool.none,
                  isSelected: drawingTool == DrawingTool.none,
                ),
                _buildToolButton(
                  context,
                  ref,
                  icon: Icons.edit,
                  tooltip: 'Pen',
                  tool: DrawingTool.pen,
                  isSelected: drawingTool == DrawingTool.pen,
                ),
                _buildToolButton(
                  context,
                  ref,
                  icon: Icons.horizontal_rule,
                  tooltip: 'Line',
                  tool: DrawingTool.line,
                  isSelected: drawingTool == DrawingTool.line,
                ),
                _buildToolButton(
                  context,
                  ref,
                  icon: Icons.rectangle_outlined,
                  tooltip: 'Rectangle',
                  tool: DrawingTool.rectangle,
                  isSelected: drawingTool == DrawingTool.rectangle,
                ),
                _buildToolButton(
                  context,
                  ref,
                  icon: Icons.circle_outlined,
                  tooltip: 'Circle',
                  tool: DrawingTool.circle,
                  isSelected: drawingTool == DrawingTool.circle,
                ),
                _buildToolButton(
                  context,
                  ref,
                  icon: Icons.auto_fix_high,
                  tooltip: 'Eraser',
                  tool: DrawingTool.eraser,
                  isSelected: drawingTool == DrawingTool.eraser,
                ),
                const SizedBox(width: 16),
                _buildColorButton(
                  context,
                  ref,
                  color: Colors.black,
                  isSelected: drawingColor == Colors.black,
                ),
                _buildColorButton(
                  context,
                  ref,
                  color: Colors.red,
                  isSelected: drawingColor == Colors.red,
                ),
                _buildColorButton(
                  context,
                  ref,
                  color: Colors.blue,
                  isSelected: drawingColor == Colors.blue,
                ),
                _buildColorButton(
                  context,
                  ref,
                  color: Colors.green,
                  isSelected: drawingColor == Colors.green,
                ),
                _buildColorButton(
                  context,
                  ref,
                  color: Colors.yellow,
                  isSelected: drawingColor == Colors.yellow,
                ),
                _buildColorButton(
                  context,
                  ref,
                  color: Colors.purple,
                  isSelected: drawingColor == Colors.purple,
                ),
                const SizedBox(width: 16),
                _buildStrokeWidthButton(
                  context,
                  ref,
                  width: 2.0,
                  isSelected: strokeWidth == 2.0,
                ),
                _buildStrokeWidthButton(
                  context,
                  ref,
                  width: 5.0,
                  isSelected: strokeWidth == 5.0,
                ),
                _buildStrokeWidthButton(
                  context,
                  ref,
                  width: 10.0,
                  isSelected: strokeWidth == 10.0,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                  onPressed: drawingHistory.undoStack.isEmpty
                      ? null
                      : () => ref.read(drawingHistoryProvider.notifier).undo(),
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  tooltip: 'Redo',
                  onPressed: drawingHistory.redoStack.isEmpty
                      ? null
                      : () => ref.read(drawingHistoryProvider.notifier).redo(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String tooltip,
    required DrawingTool tool,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ref.read(drawingToolProvider.notifier).state = tool;
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : null,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(
    BuildContext context,
    WidgetRef ref, {
    required Color color,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: 'Color',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ref.read(drawingColorProvider.notifier).state = color;
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrokeWidthButton(
    BuildContext context,
    WidgetRef ref, {
    required double width,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: 'Stroke Width',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ref.read(strokeWidthProvider.notifier).state = width;
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                width: 30,
                height: width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(width / 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
