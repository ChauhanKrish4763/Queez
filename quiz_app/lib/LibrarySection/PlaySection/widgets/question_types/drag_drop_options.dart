import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/utils/color.dart';

class DragDropOptions extends StatefulWidget {
  final Question question;
  final dynamic userAnswer;
  final ValueChanged<dynamic> onAnswerSelected;
  final ScrollController? scrollController;

  const DragDropOptions({
    super.key,
    required this.question,
    this.userAnswer,
    required this.onAnswerSelected,
    this.scrollController,
  });

  @override
  State<DragDropOptions> createState() => _DragDropOptionsState();
}

class _DragDropOptionsState extends State<DragDropOptions> {
  late Map<String, String?> _dropTargetValues;
  late List<String> _availableDragItems;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _initializeState() {
    // Initialize drop targets with null values
    _dropTargetValues = {};
    for (var target in widget.question.dropTargets ?? []) {
      _dropTargetValues[target] = null;
    }

    // Initialize available drag items
    _availableDragItems = List.from(widget.question.dragItems ?? []);

    // If userAnswer exists, restore the state
    if (widget.userAnswer != null && widget.userAnswer is Map) {
      final Map<String, String> answer = Map<String, String>.from(
        widget.userAnswer,
      );
      _dropTargetValues = Map<String, String?>.from(answer);

      // Remove already placed items from available items
      for (var placedItem in answer.values) {
        _availableDragItems.remove(placedItem);
      }
    }
  }

  void _onDragItemPlaced(String target, String item) {
    setState(() {
      // Remove item from its previous target if it was placed
      _dropTargetValues.forEach((key, value) {
        if (value == item) {
          _dropTargetValues[key] = null;
        }
      });

      // Place item in new target
      _dropTargetValues[target] = item;

      // Remove from available items if not already removed
      _availableDragItems.remove(item);
    });

    // Check if all targets are filled
    if (!_dropTargetValues.values.contains(null)) {
      // Convert to Map<String, String> for submission
      final answer = Map<String, String>.fromEntries(
        _dropTargetValues.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
      widget.onAnswerSelected(answer);
    }
  }

  void _onDragItemRemoved(String target) {
    setState(() {
      final item = _dropTargetValues[target];
      if (item != null) {
        _dropTargetValues[target] = null;
        _availableDragItems.add(item);
      }
    });
  }

  void _startAutoScroll(DragUpdateDetails details) {
    if (widget.scrollController == null) return;

    final scrollController = widget.scrollController!;
    final screenHeight = MediaQuery.of(context).size.height;
    final scrollEdgeThreshold = 100.0;
    final scrollSpeed = 5.0;

    // Get the drag position
    final dragY = details.globalPosition.dy;

    // Cancel existing timer
    _scrollTimer?.cancel();

    // Check if near top or bottom edge
    if (dragY < scrollEdgeThreshold) {
      // Near top - scroll up
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (scrollController.hasClients) {
          final newOffset = scrollController.offset - scrollSpeed;
          if (newOffset >= scrollController.position.minScrollExtent) {
            scrollController.jumpTo(newOffset);
          } else {
            scrollController.jumpTo(scrollController.position.minScrollExtent);
            timer.cancel();
          }
        }
      });
    } else if (dragY > screenHeight - scrollEdgeThreshold) {
      // Near bottom - scroll down
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (scrollController.hasClients) {
          final newOffset = scrollController.offset + scrollSpeed;
          if (newOffset <= scrollController.position.maxScrollExtent) {
            scrollController.jumpTo(newOffset);
          } else {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
            timer.cancel();
          }
        }
      });
    } else {
      // Not near edges - stop scrolling
      _scrollTimer?.cancel();
    }
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.dragItems == null ||
        widget.question.dropTargets == null ||
        widget.question.dragItems!.isEmpty ||
        widget.question.dropTargets!.isEmpty) {
      return const Center(
        child: Text(
          'Invalid drag and drop question',
          style: TextStyle(fontSize: 16, color: AppColors.error),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Drag items to their matching pairs',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Drop Targets
        Text(
          'Match the pairs:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        ...widget.question.dropTargets!.map((target) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDropTarget(target, _dropTargetValues[target]),
          );
        }),

        const SizedBox(height: 32),

        // Available Drag Items
        if (_availableDragItems.isNotEmpty) ...[
          Text(
            'Available items:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                _availableDragItems.map((item) {
                  return _buildDraggableItem(item);
                }).toList(),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'All items placed!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropTarget(String target, String? placedItem) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (data) => _onDragItemPlaced(target, data as String),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                placedItem != null
                    ? AppColors.white
                    : isHovering
                    ? AppColors.accentLight
                    : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  placedItem != null
                      ? AppColors.primary
                      : isHovering
                      ? AppColors.primary
                      : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Target Label
              Expanded(
                flex: 2,
                child: Text(
                  target,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Arrow
              Icon(
                Icons.arrow_forward,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 20,
              ),
              const SizedBox(width: 12),

              // Placed Item or Empty Slot
              Expanded(
                flex: 2,
                child:
                    placedItem != null
                        ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  placedItem,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _onDragItemRemoved(target),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                        : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.3,
                              ),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Drop here',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
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
      onDragUpdate: _startAutoScroll,
      onDragEnd: (details) => _stopAutoScroll(),
      onDraggableCanceled: (velocity, offset) => _stopAutoScroll(),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accentBright,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBright.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildItemChip(item)),
      child: _buildItemChip(item),
    );
  }

  Widget _buildItemChip(String item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
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
          Icon(Icons.drag_indicator, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            item,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
