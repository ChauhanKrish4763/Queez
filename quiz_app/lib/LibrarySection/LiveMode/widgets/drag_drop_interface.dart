import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Widget that displays a drag and drop interface for matching items to targets in live multiplayer quiz
/// Shows fixed drag items on top and drop targets below for users to match
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
  // Track which drag item is matched to which drop target
  // Key: dropTarget, Value: dragItem
  late Map<String, String?> _matches;
  
  // Preserve final state after submission to prevent state loss
  Map<String, String>? _submittedMatches;
  
  // Track optimistic updates to prevent external state overwrites
  bool _pendingChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void didUpdateWidget(DragDropInterface oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    debugPrint('🔄 DRAG_DROP - didUpdateWidget called');
    debugPrint('🔄 DRAG_DROP - hasAnswered: ${widget.hasAnswered}, pendingChanges: $_pendingChanges');
    
    // Only reset state if items or targets have changed
    if (oldWidget.dragItems != widget.dragItems ||
        oldWidget.dropTargets != widget.dropTargets) {
      debugPrint('🔄 DRAG_DROP - Items/targets changed, reinitializing');
      _initializeState();
      return;
    }
    
    // Preserve local state when pending changes exist
    // This prevents external state updates from overwriting user actions
    if (_pendingChanges) {
      debugPrint('🔄 DRAG_DROP - Pending changes exist, ignoring external updates');
      // Don't accept new props while user is actively making changes
      return;
    }
    
    // If we've already submitted, preserve the submitted state
    if (widget.hasAnswered && _submittedMatches != null) {
      debugPrint('🔄 DRAG_DROP - Already submitted, preserving state');
      // Don't reset state after submission
      return;
    }
  }

  void _initializeState() {
    // Initialize all drop targets as empty
    _matches = {for (var target in widget.dropTargets) target: null};
    // Initialize state preservation variables
    _submittedMatches = null;
    _pendingChanges = false;
  }

  bool get _allItemsPlaced {
    return _matches.values.every((item) => item != null);
  }

  void _handleSubmit() {
    if (_allItemsPlaced && !widget.hasAnswered) {
      debugPrint('📤 DRAG_DROP - Submitting matches: $_matches');
      
      // Build the matches map (dragItem -> dropTarget)
      final userMatches = <String, String>{};
      _matches.forEach((target, dragItem) {
        if (dragItem != null) {
          userMatches[dragItem] = target;
        }
      });
      
      // Preserve the submitted matches to prevent state loss
      // ✅ FIX: Only include non-null values to prevent empty string issues
      setState(() {
        _submittedMatches = <String, String>{};
        _matches.forEach((target, dragItem) {
          if (dragItem != null && dragItem.isNotEmpty) {
            _submittedMatches![target] = dragItem;
          }
        });
        // Clear pending changes flag since we're submitting
        _pendingChanges = false;
      });
      
      debugPrint('📤 DRAG_DROP - Submitted matches preserved: $_submittedMatches');
      
      widget.onMatchSubmit(userMatches);
    }
  }

  void _handleItemPlaced(String dropTarget, String dragItem) {
    if (widget.hasAnswered) return; // Don't allow changes after submission

    debugPrint('🎯 DRAG_DROP - Item placed: $dragItem -> $dropTarget');

    setState(() {
      // Remove dragItem from its previous position if it was already placed
      String? previousTarget;
      _matches.forEach((target, item) {
        if (item == dragItem) {
          previousTarget = target;
        }
      });

      if (previousTarget != null) {
        debugPrint('🎯 DRAG_DROP - Removing $dragItem from previous target: $previousTarget');
        _matches[previousTarget!] = null;
      }

      // If the drop target already has an item, it will be replaced
      _matches[dropTarget] = dragItem;
      
      // Set pending changes flag to prevent external state overwrites
      // DO NOT clear this flag with a timeout - keep it until submission
      _pendingChanges = true;
      
      debugPrint('🎯 DRAG_DROP - Current matches: $_matches');
      debugPrint('🎯 DRAG_DROP - Pending changes: $_pendingChanges');
    });

    // Force rebuild immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
    
    // ❌ REMOVED: The 2-second timeout that was causing items to revert
    // The _pendingChanges flag will stay true until submission or widget reset
  }

  void _handleItemRemoved(String dropTarget) {
    if (widget.hasAnswered) return; // Don't allow changes after submission

    setState(() {
      _matches[dropTarget] = null;
    });
  }

  // Check if a drag item is already placed somewhere
  bool _isItemPlaced(String dragItem) {
    return _matches.values.contains(dragItem);
  }

  @override
  Widget build(BuildContext context) {
    // Determine border color based on answer state
    Color feedbackColor;
    if (widget.hasAnswered) {
      if (widget.isCorrect == true) {
        feedbackColor = AppColors.success;
      } else if (widget.isCorrect == false) {
        feedbackColor = AppColors.error;
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
              Icon(Icons.info_outline, color: QuizColors.info, size: 20),
              const SizedBox(width: QuizSpacing.sm),
              Expanded(
                child: Text(
                  'Drag items to match them with the correct targets',
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

        // Fixed Drag Items Section
        Text(
          'Items to Match:',
          style: QuizTextStyles.optionText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: QuizSpacing.md),
        Wrap(
          spacing: QuizSpacing.md,
          runSpacing: QuizSpacing.md,
          children:
              widget.dragItems.map((item) {
                final isPlaced = _isItemPlaced(item);
                return _buildDraggableItem(item, isPlaced);
              }).toList(),
        ),
        const SizedBox(height: QuizSpacing.xl),

        // Drop Targets Section
        Text(
          'Drop Targets:',
          style: QuizTextStyles.optionText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: QuizSpacing.md),
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
            children:
                widget.dropTargets
                    .map((target) => _buildDropZone(target))
                    .toList(),
          ),
        ),
        const SizedBox(height: QuizSpacing.lg),

        // Submit button
        ElevatedButton(
          onPressed:
              (_allItemsPlaced && !widget.hasAnswered) ? _handleSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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
                    : (_allItemsPlaced
                        ? 'Submit Matches'
                        : 'Match all items first'),
                style: QuizTextStyles.optionText.copyWith(
                  color:
                      widget.hasAnswered || !_allItemsPlaced
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

  Widget _buildDropZone(String dropTarget) {
    // Use submitted matches when hasAnswered is true to preserve state
    final matchedItem = widget.hasAnswered && _submittedMatches != null
        ? _submittedMatches![dropTarget]
        : _matches[dropTarget];
    final isEmpty = matchedItem == null || matchedItem.isEmpty;

    debugPrint('🎨 DROP_ZONE - Building zone for: $dropTarget');
    debugPrint('🎨 DROP_ZONE - hasAnswered: ${widget.hasAnswered}');
    debugPrint('🎨 DROP_ZONE - _submittedMatches: $_submittedMatches');
    debugPrint('🎨 DROP_ZONE - _matches: ${_matches[dropTarget]}');
    debugPrint('🎨 DROP_ZONE - matchedItem: $matchedItem');
    debugPrint('🎨 DROP_ZONE - isEmpty: $isEmpty');

    // Check if this match is correct (only after submission)
    bool? isCorrectMatch;
    if (widget.hasAnswered &&
        widget.correctMatches != null &&
        matchedItem != null &&
        matchedItem.isNotEmpty) {
      debugPrint('🔍 DROP_ZONE - Checking match: $matchedItem -> $dropTarget');
      debugPrint('🔍 DROP_ZONE - Correct matches: ${widget.correctMatches}');

      isCorrectMatch = widget.correctMatches![matchedItem] == dropTarget;
      debugPrint('🔍 DROP_ZONE - Is correct? $isCorrectMatch');
    }

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !widget.hasAnswered,
      onAcceptWithDetails:
          (details) => _handleItemPlaced(dropTarget, details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        // Determine colors based on correctness
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
            backgroundColor = AppColors.error.withValues(alpha: 0.15);
            borderColor = AppColors.error;
            itemBackgroundColor = AppColors.error;
            itemTextColor = Colors.white;
          } else {
            backgroundColor = AppColors.white;
            borderColor = Colors.grey.shade300;
            itemBackgroundColor = Colors.grey.shade200;
            itemTextColor = AppColors.textPrimary;
          }
        } else {
          backgroundColor =
              isEmpty
                  ? (isHovering
                      ? AppColors.accentLight
                      : AppColors.primaryLight)
                  : AppColors.white;
          borderColor =
              isEmpty
                  ? (isHovering ? AppColors.primary : Colors.grey.shade300)
                  : AppColors.primary;
          itemBackgroundColor = AppColors.primary.withValues(alpha: 0.1);
          itemTextColor = QuizColors.textPrimary;
        }

        return AnimatedContainer(
          duration: QuizAnimations.normal,
          margin: const EdgeInsets.symmetric(
            vertical: QuizSpacing.xs,
            horizontal: QuizSpacing.md,
          ),
          padding: const EdgeInsets.all(QuizSpacing.md),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(QuizBorderRadius.md),
            border: Border.all(
              color: borderColor,
              width: widget.hasAnswered && !isEmpty ? 3 : (isHovering ? 2 : 1),
            ),
            boxShadow:
                isEmpty
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
                  padding: const EdgeInsets.all(QuizSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
                  ),
                  child: Text(
                    dropTarget,
                    style: QuizTextStyles.optionText.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: QuizSpacing.md),

              // Arrow
              Icon(
                Icons.arrow_forward,
                color: isEmpty ? Colors.grey.shade400 : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: QuizSpacing.md),

              // Matched item or placeholder
              Expanded(
                flex: 2,
                child:
                    isEmpty
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
                            color: itemBackgroundColor,
                            borderRadius: BorderRadius.circular(
                              QuizBorderRadius.sm,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  matchedItem,
                                  style: QuizTextStyles.optionText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: itemTextColor,
                                  ),
                                ),
                              ),
                              if (widget.hasAnswered &&
                                  isCorrectMatch != null) ...[
                                const SizedBox(width: QuizSpacing.xs),
                                Icon(
                                  isCorrectMatch
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: itemTextColor,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
              ),

              // Remove button (only if item is placed and not answered)
              if (!isEmpty && !widget.hasAnswered)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _handleItemRemoved(dropTarget),
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

  Widget _buildDraggableItem(String item, bool isPlaced) {
    if (widget.hasAnswered) {
      // Show as static chip when answered
      return _buildItemChip(item, isPlaced, isStatic: true);
    }

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
            color: AppColors.accentBright,
            borderRadius: BorderRadius.circular(QuizBorderRadius.md),
          ),
          child: Text(
            item,
            style: QuizTextStyles.optionText.copyWith(color: Colors.white),
          ),
        ),
      ),
      // 🔥 FIX: Keep item visible but slightly transparent when dragging
      childWhenDragging: Opacity(
        opacity: 0.5, // Changed from 0.3 to 0.5 for better visibility
        child: _buildItemChip(item, isPlaced),
      ),
      // 🔥 FIX: Show item clearly when NOT dragging
      child:
          isPlaced
              ? Opacity(
                opacity: 0.4, // Greyed out when placed
                child: _buildItemChip(item, true),
              )
              : _buildItemChip(item, false), // Full visibility when available
    );
  }

  Widget _buildItemChip(String item, bool isPlaced, {bool isStatic = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: QuizSpacing.md,
        vertical: QuizSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isPlaced ? Colors.grey.shade200 : AppColors.white,
        borderRadius: BorderRadius.circular(QuizBorderRadius.md),
        border: Border.all(
          color: isPlaced ? Colors.grey.shade400 : AppColors.primary,
          width: 1,
        ),
        boxShadow:
            isPlaced
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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isStatic)
            Icon(
              Icons.drag_indicator,
              color: isPlaced ? Colors.grey.shade400 : AppColors.primary,
              size: 20,
            ),
          if (!isStatic) const SizedBox(width: QuizSpacing.sm),
          Text(
            item,
            style: QuizTextStyles.optionText.copyWith(
              color: isPlaced ? Colors.grey.shade600 : null,
            ),
          ),
        ],
      ),
    );
  }
}
