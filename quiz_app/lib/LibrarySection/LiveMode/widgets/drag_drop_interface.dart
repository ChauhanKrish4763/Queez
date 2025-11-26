import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class DragDropInterface extends StatefulWidget {
  final List<String> dragItems;
  final List<String> dropTargets;
  final Function(Map<String, String>) onMatchSubmit;
  final bool hasAnswered;
  final bool? isCorrect;
  final Map<String, String>? correctMatches;

  const DragDropInterface({
    super.key,
    required this.dragItems,
    required this.dropTargets,
    required this.onMatchSubmit,
    required this.hasAnswered,
    this.isCorrect,
    this.correctMatches,
  });

  @override
  State<DragDropInterface> createState() => _DragDropInterfaceState();
}

class _DragDropInterfaceState extends State<DragDropInterface> {
  late Map<String, String?> _matches;
  Map<String, String>? _frozenSubmittedMatches;
  bool _hasEverSubmitted = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeState();
    debugPrint('📝 DRAG_DROP - Initialized with ${widget.dragItems.length} items and ${widget.dropTargets.length} targets');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DragDropInterface oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only reinitialize if question changed (different items/targets)
    if (!_listEquals(oldWidget.dragItems, widget.dragItems) ||
        !_listEquals(oldWidget.dropTargets, widget.dropTargets)) {
      debugPrint('📝 DRAG_DROP - Question changed, reinitializing state');
      _initializeState();
      return;
    }
    
    // Don't reset state after submission
    if (_hasEverSubmitted) {
      debugPrint('📝 DRAG_DROP - Already submitted, keeping frozen state');
      return;
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _initializeState() {
    _matches = {for (var target in widget.dropTargets) target: null};
    _frozenSubmittedMatches = null;
    _hasEverSubmitted = false;
    debugPrint('📝 DRAG_DROP - State initialized: $_matches');
  }

  bool get _allItemsPlaced {
    final allPlaced = _matches.values.every((item) => item != null && item.isNotEmpty);
    debugPrint('📝 DRAG_DROP - All items placed: $allPlaced, matches: $_matches');
    return allPlaced;
  }

  void _handleSubmit() {
    if (_allItemsPlaced && !widget.hasAnswered) {
      final userMatches = <String, String>{};
      _matches.forEach((target, dragItem) {
        if (dragItem != null && dragItem.isNotEmpty) {
          userMatches[dragItem] = target;
        }
      });

      debugPrint('📝 DRAG_DROP - Submitting matches: $userMatches');

      setState(() {
        _frozenSubmittedMatches = Map<String, String>.unmodifiable(
          Map.fromEntries(
            _matches.entries
                .where((e) => e.value != null && e.value!.isNotEmpty)
                .map((e) => MapEntry(e.key, e.value!)),
          ),
        );
        _hasEverSubmitted = true;
      });
      widget.onMatchSubmit(userMatches);
    }
  }

  void _handleItemPlaced(String dropTarget, String dragItem) {
    if (widget.hasAnswered || _hasEverSubmitted) {
      debugPrint('📝 DRAG_DROP - Cannot place item, already answered or submitted');
      return;
    }
    
    debugPrint('📝 DRAG_DROP - Placing "$dragItem" into "$dropTarget"');
    
    setState(() {
      // Remove item from any previous target
      String? previousTarget;
      _matches.forEach((target, item) {
        if (item == dragItem) {
          previousTarget = target;
        }
      });
      if (previousTarget != null) {
        debugPrint('📝 DRAG_DROP - Removing "$dragItem" from previous target "$previousTarget"');
        _matches[previousTarget!] = null;
      }
      
      // Place item in new target
      _matches[dropTarget] = dragItem;
    });
    
    debugPrint('📝 DRAG_DROP - Updated matches: $_matches');
  }

  void _handleItemRemoved(String dropTarget) {
    if (widget.hasAnswered || _hasEverSubmitted) return;
    
    debugPrint('📝 DRAG_DROP - Removing item from "$dropTarget"');
    setState(() {
      _matches[dropTarget] = null;
    });
  }

  bool _isItemPlaced(String dragItem) {
    return _matches.values.contains(dragItem);
  }

  @override
  Widget build(BuildContext context) {
    Color feedbackColor;
    if (widget.hasAnswered) {
      if (widget.isCorrect == true) {
        feedbackColor = AppColors.success;
      } else if (widget.isCorrect == false) {
        feedbackColor = const Color(0xFFE53935);
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Drag items and drop them on matching targets',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Items to drag
        Text(
          'Items to Match:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.dragItems.map((item) {
            final isPlaced = _isItemPlaced(item);
            return _buildDraggableItem(item, isPlaced);
          }).toList(),
        ),
        const SizedBox(height: 24),
        
        // Drop targets
        Text(
          'Drop Targets:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            border: Border.all(
              color: feedbackColor,
              width: widget.hasAnswered ? 3 : 0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: widget.dropTargets.map((target) => _buildDropZone(target)).toList(),
          ),
        ),
        const SizedBox(height: 20),
        
        // Submit button
        ElevatedButton(
          onPressed: (_allItemsPlaced && !widget.hasAnswered && !_hasEverSubmitted) 
              ? _handleSubmit 
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 10),
              ],
              Text(
                widget.hasAnswered
                    ? (widget.isCorrect == true ? 'Correct!' : 'Incorrect')
                    : (_allItemsPlaced ? 'Submit Matches' : 'Match all items first'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropZone(String dropTarget) {
    final String? matchedItem;

    if (_hasEverSubmitted && _frozenSubmittedMatches != null) {
      matchedItem = _frozenSubmittedMatches![dropTarget];
    } else {
      matchedItem = _matches[dropTarget];
    }

    final isEmpty = matchedItem == null || matchedItem.isEmpty;

    bool? isCorrectMatch;
    if (widget.hasAnswered &&
        widget.correctMatches != null &&
        matchedItem != null &&
        matchedItem.isNotEmpty) {
      isCorrectMatch = widget.correctMatches![matchedItem] == dropTarget;
    }

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        if (widget.hasAnswered || _hasEverSubmitted) return false;
        debugPrint('📝 DRAG_DROP - Will accept "${details.data}" on "$dropTarget"');
        return true;
      },
      onAcceptWithDetails: (details) {
        debugPrint('📝 DRAG_DROP - Accepted "${details.data}" on "$dropTarget"');
        _handleItemPlaced(dropTarget, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        Color backgroundColor;
        Color borderColor;
        Color itemBackgroundColor;
        Color itemTextColor;

        if (widget.hasAnswered && !isEmpty) {
          if (isCorrectMatch == true) {
            backgroundColor = AppColors.success.withValues(alpha: 0.15);
            borderColor = AppColors.success;
            itemBackgroundColor = AppColors.success;
            itemTextColor = Colors.white;
          } else if (isCorrectMatch == false) {
            backgroundColor = const Color(0xFFE53935).withValues(alpha: 0.15);
            borderColor = const Color(0xFFE53935);
            itemBackgroundColor = const Color(0xFFE53935);
            itemTextColor = Colors.white;
          } else {
            backgroundColor = AppColors.white;
            borderColor = Colors.grey.shade300;
            itemBackgroundColor = Colors.grey.shade200;
            itemTextColor = AppColors.textPrimary;
          }
        } else {
          backgroundColor = isEmpty
              ? (isHovering ? AppColors.accentLight : AppColors.primaryLight.withValues(alpha: 0.3))
              : AppColors.white;
          borderColor = isEmpty
              ? (isHovering ? AppColors.primary : Colors.grey.shade300)
              : AppColors.primary;
          itemBackgroundColor = AppColors.primary.withValues(alpha: 0.1);
          itemTextColor = AppColors.textPrimary;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: widget.hasAnswered && !isEmpty ? 2.5 : (isHovering ? 2 : 1.5),
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dropTarget,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward,
                color: isEmpty ? Colors.grey.shade400 : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              
              // Drop area / matched item
              Expanded(
                flex: 2,
                child: isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isHovering 
                              ? AppColors.accentLight 
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isHovering 
                                ? AppColors.primary 
                                : Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Text(
                          'Drop here',
                          style: TextStyle(
                            color: isHovering 
                                ? AppColors.primary 
                                : AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: itemBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                matchedItem!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: itemTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (widget.hasAnswered && isCorrectMatch != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                isCorrectMatch ? Icons.check_circle : Icons.cancel,
                                color: itemTextColor,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
              
              // Remove button (only when not answered)
              if (!isEmpty && !widget.hasAnswered && !_hasEverSubmitted)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _handleItemRemoved(dropTarget),
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(String item, bool isPlaced) {
    if (widget.hasAnswered || _hasEverSubmitted) {
      return _buildItemChip(item, isPlaced, isStatic: true);
    }
    
    return LongPressDraggable<String>(
      data: item,
      delay: const Duration(milliseconds: 100),
      onDragStarted: () {
        debugPrint('📝 DRAG_DROP - Started dragging "$item"');
      },
      onDragEnd: (details) {
        debugPrint('📝 DRAG_DROP - Ended dragging "$item", wasAccepted: ${details.wasAccepted}');
      },
      onDraggableCanceled: (velocity, offset) {
        debugPrint('📝 DRAG_DROP - Drag cancelled for "$item"');
      },
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accentBright,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBright.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            item,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _buildItemChip(item, true),
      ),
      child: isPlaced
          ? Opacity(opacity: 0.5, child: _buildItemChip(item, true))
          : _buildItemChip(item, false),
    );
  }

  Widget _buildItemChip(String item, bool isPlaced, {bool isStatic = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPlaced ? Colors.grey.shade200 : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPlaced ? Colors.grey.shade400 : AppColors.primary,
          width: 1.5,
        ),
        boxShadow: isPlaced
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isStatic && !isPlaced)
            Icon(
              Icons.drag_indicator,
              color: AppColors.primary,
              size: 18,
            ),
          if (!isStatic && !isPlaced) const SizedBox(width: 6),
          Text(
            item,
            style: TextStyle(
              color: isPlaced ? Colors.grey.shade600 : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
