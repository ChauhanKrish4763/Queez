import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Widget that displays a drag and drop interface for ordering items in live multiplayer quiz
/// Allows participants to drag items into the correct order with visual feedback after submission
class DragDropInterface extends StatefulWidget {
  final List<String> items;
  final Function(List<String>) onOrderSubmit;
  final bool hasAnswered;
  final bool? isCorrect;

  const DragDropInterface({
    super.key,
    required this.items,
    required this.onOrderSubmit,
    required this.hasAnswered,
    this.isCorrect,
  });

  @override
  State<DragDropInterface> createState() => _DragDropInterfaceState();
}

class _DragDropInterfaceState extends State<DragDropInterface> {
  // Track the current order of items in drop zones
  late List<String?> _dropZoneItems;
  // Track which items are still available to drag
  late List<String> _availableItems;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void didUpdateWidget(DragDropInterface oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset state if items change
    if (oldWidget.items != widget.items) {
      _initializeState();
    }
  }

  void _initializeState() {
    // Initialize drop zones as empty
    _dropZoneItems = List<String?>.filled(widget.items.length, null);
    // All items start as available to drag
    _availableItems = List<String>.from(widget.items);
  }

  bool get _allItemsPlaced {
    return _dropZoneItems.every((item) => item != null);
  }

  void _handleSubmit() {
    if (_allItemsPlaced && !widget.hasAnswered) {
      // Filter out nulls and submit the order
      final orderedItems = _dropZoneItems.whereType<String>().toList();
      widget.onOrderSubmit(orderedItems);
    }
  }

  void _handleItemPlaced(int dropIndex, String item) {
    if (widget.hasAnswered) return; // Don't allow changes after submission

    setState(() {
      // Remove item from its previous position if it was already placed
      final previousIndex = _dropZoneItems.indexOf(item);
      if (previousIndex != -1) {
        _dropZoneItems[previousIndex] = null;
      } else {
        // Remove from available items if it's being placed for the first time
        _availableItems.remove(item);
      }

      // Place item in new position
      // If the drop zone already has an item, swap them
      final existingItem = _dropZoneItems[dropIndex];
      if (existingItem != null) {
        _availableItems.add(existingItem);
      }

      _dropZoneItems[dropIndex] = item;
    });
  }

  void _handleItemRemoved(int dropIndex) {
    if (widget.hasAnswered) return; // Don't allow changes after submission

    setState(() {
      final item = _dropZoneItems[dropIndex];
      if (item != null) {
        _dropZoneItems[dropIndex] = null;
        _availableItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine border color based on answer state
    Color feedbackColor;
    if (widget.hasAnswered) {
      if (widget.isCorrect == true) {
        feedbackColor = QuizColors.correct;
      } else if (widget.isCorrect == false) {
        feedbackColor = QuizColors.incorrect;
      } else {
        feedbackColor = Colors.grey.shade300;
      }
    } else {
      feedbackColor = Colors.transparent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(QuizSpacing.md),
          decoration: BoxDecoration(
            color: QuizColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(QuizBorderRadius.md),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: QuizColors.info,
                size: 20,
              ),
              const SizedBox(width: QuizSpacing.sm),
              Expanded(
                child: Text(
                  'Drag items into the correct order',
                  style: QuizTextStyles.optionText.copyWith(
                    fontSize: 14,
                    color: QuizColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: QuizSpacing.lg),

        // Drop zones
        AnimatedContainer(
          duration: QuizAnimations.normal,
          decoration: BoxDecoration(
            border: Border.all(
              color: feedbackColor,
              width: widget.hasAnswered ? 3 : 0,
            ),
            borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
          ),
          child: Column(
            children: List.generate(
              widget.items.length,
              (index) => _buildDropZone(index),
            ),
          ),
        ),
        const SizedBox(height: QuizSpacing.lg),

        // Available items to drag
        if (_availableItems.isNotEmpty && !widget.hasAnswered) ...[
          Text(
            'Available Items:',
            style: QuizTextStyles.optionText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: QuizSpacing.md),
          Wrap(
            spacing: QuizSpacing.md,
            runSpacing: QuizSpacing.md,
            children: _availableItems.map((item) => _buildDraggableItem(item)).toList(),
          ),
          const SizedBox(height: QuizSpacing.lg),
        ],

        // Submit button
        ElevatedButton(
          onPressed: (_allItemsPlaced && !widget.hasAnswered) ? _handleSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(
              vertical: QuizSpacing.md,
              horizontal: QuizSpacing.xl,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
            ),
            elevation: widget.hasAnswered || !_allItemsPlaced ? 0 : 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.hasAnswered && widget.isCorrect != null) ...[
                Icon(
                  widget.isCorrect! ? Icons.check_circle : Icons.cancel,
                  size: 24,
                ),
                const SizedBox(width: QuizSpacing.sm),
              ],
              Text(
                widget.hasAnswered
                    ? 'Submitted'
                    : (_allItemsPlaced ? 'Submit Order' : 'Place all items first'),
                style: QuizTextStyles.optionText.copyWith(
                  color: widget.hasAnswered || !_allItemsPlaced
                      ? Colors.grey.shade600
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropZone(int index) {
    final item = _dropZoneItems[index];
    final isEmpty = item == null;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !widget.hasAnswered,
      onAcceptWithDetails: (details) => _handleItemPlaced(index, details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: QuizAnimations.normal,
          margin: const EdgeInsets.symmetric(
            vertical: QuizSpacing.xs,
            horizontal: QuizSpacing.md,
          ),
          padding: const EdgeInsets.all(QuizSpacing.md),
          decoration: BoxDecoration(
            color: isEmpty
                ? (isHovering
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Colors.grey.shade100)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(QuizBorderRadius.md),
            border: Border.all(
              color: isEmpty
                  ? (isHovering
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300)
                  : Theme.of(context).primaryColor,
              width: isHovering ? 2 : 1,
            ),
            boxShadow: isEmpty
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Position number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isEmpty
                      ? Colors.grey.shade300
                      : Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isEmpty ? QuizColors.textSecondary : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: QuizSpacing.md),
              // Item content or placeholder
              Expanded(
                child: isEmpty
                    ? Text(
                        'Drop item here',
                        style: QuizTextStyles.optionText.copyWith(
                          color: QuizColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Row(
                        children: [
                          if (!widget.hasAnswered)
                            Icon(
                              Icons.drag_indicator,
                              color: QuizColors.textSecondary,
                              size: 20,
                            ),
                          if (!widget.hasAnswered) const SizedBox(width: QuizSpacing.sm),
                          Expanded(
                            child: Text(
                              item,
                              style: QuizTextStyles.optionText,
                            ),
                          ),
                        ],
                      ),
              ),
              // Remove button (only if item is placed and not answered)
              if (!isEmpty && !widget.hasAnswered)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _handleItemRemoved(index),
                  color: QuizColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(String item) {
    return Draggable<String>(
      data: item,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(QuizBorderRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: QuizSpacing.md,
            vertical: QuizSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(QuizBorderRadius.md),
          ),
          child: Text(
            item,
            style: QuizTextStyles.optionText.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildItemChip(item),
      ),
      child: _buildItemChip(item),
    );
  }

  Widget _buildItemChip(String item) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: QuizSpacing.md,
        vertical: QuizSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(QuizBorderRadius.md),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_indicator,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: QuizSpacing.sm),
          Text(
            item,
            style: QuizTextStyles.optionText,
          ),
        ],
      ),
    );
  }
}
