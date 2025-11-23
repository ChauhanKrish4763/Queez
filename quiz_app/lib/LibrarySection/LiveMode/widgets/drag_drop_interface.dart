import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Widget that displays a drag and drop interface for matching items in live multiplayer quiz
/// Allows participants to drag items to their matching targets with visual feedback after submission
class DragDropInterface extends StatefulWidget {
  final List<String> items; // dragItems
  final List<String>? dropTargets; // drop targets to match with items
  final Function(Map<String, String>) onOrderSubmit;
  final bool hasAnswered;
  final bool? isCorrect;

  const DragDropInterface({
    super.key,
    required this.items,
    this.dropTargets,
    required this.onOrderSubmit,
    required this.hasAnswered,
    this.isCorrect,
  });

  @override
  State<DragDropInterface> createState() => _DragDropInterfaceState();
}

class _DragDropInterfaceState extends State<DragDropInterface> {
  // Track the mapping of drop targets to placed items
  late Map<String, String?> _dropTargetValues;
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
    if (oldWidget.items != widget.items || oldWidget.dropTargets != widget.dropTargets) {
      _initializeState();
    }
  }

  void _initializeState() {
    // Initialize drop targets with null values
    _dropTargetValues = {};
    final targets = widget.dropTargets ?? widget.items;
    for (var target in targets) {
      _dropTargetValues[target] = null;
    }
    
    // All items start as available to drag
    _availableItems = List<String>.from(widget.items);
  }

  bool get _allItemsPlaced {
    return !_dropTargetValues.values.contains(null);
  }

  void _handleSubmit() {
    if (_allItemsPlaced && !widget.hasAnswered) {
      // Convert to Map<String, String> for submission
      final answer = Map<String, String>.fromEntries(
        _dropTargetValues.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
      widget.onOrderSubmit(answer);
    }
  }

  void _handleItemPlaced(String target, String item) {
    if (widget.hasAnswered) return; // Don't allow changes after submission

    setState(() {
      // Remove item from its previous target if it was placed
      _dropTargetValues.forEach((key, value) {
        if (value == item) {
          _dropTargetValues[key] = null;
        }
      });

      // Place item in new target
      // If the target already has an item, return it to available items
      final existingItem = _dropTargetValues[target];
      if (existingItem != null) {
        _availableItems.add(existingItem);
      }

      _dropTargetValues[target] = item;
      
      // Remove from available items if not already removed
      _availableItems.remove(item);
    });
  }

  void _handleItemRemoved(String target) {
    if (widget.hasAnswered) return; // Don't allow changes after submission

    setState(() {
      final item = _dropTargetValues[target];
      if (item != null) {
        _dropTargetValues[target] = null;
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
            children: (widget.dropTargets ?? widget.items).map((target) => _buildDropZone(target)).toList(),
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

  Widget _buildDropZone(String target) {
    final placedItem = _dropTargetValues[target];
    final isEmpty = placedItem == null;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !widget.hasAnswered,
      onAcceptWithDetails: (details) => _handleItemPlaced(target, details.data),
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
              // Target label
              Expanded(
                flex: 2,
                child: Text(
                  target,
                  style: QuizTextStyles.optionText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: QuizSpacing.md),
              // Arrow
              Icon(
                Icons.arrow_forward,
                color: QuizColors.textSecondary.withValues(alpha: 0.5),
                size: 20,
              ),
              const SizedBox(width: QuizSpacing.md),
              // Placed item or placeholder
              Expanded(
                flex: 2,
                child: isEmpty
                    ? Text(
                        'Drop here',
                        style: QuizTextStyles.optionText.copyWith(
                          color: QuizColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: QuizSpacing.sm,
                          vertical: QuizSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!widget.hasAnswered)
                              Icon(
                                Icons.drag_indicator,
                                color: Colors.white,
                                size: 16,
                              ),
                            if (!widget.hasAnswered) const SizedBox(width: QuizSpacing.xs),
                            Expanded(
                              child: Text(
                                placedItem,
                                style: QuizTextStyles.optionText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              // Remove button (only if item is placed and not answered)
              if (!isEmpty && !widget.hasAnswered)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _handleItemRemoved(target),
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
