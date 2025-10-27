import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';
import 'drag_drop_pair.dart';

class DragDropContent extends StatelessWidget {
  final List<TextEditingController> dragItemControllers;
  final List<TextEditingController> dropTargetControllers;
  final VoidCallback onAddPair;
  final VoidCallback onRemovePair;
  final bool isLocked;

  const DragDropContent({
    super.key,
    required this.dragItemControllers,
    required this.dropTargetControllers,
    required this.onAddPair,
    required this.onRemovePair,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildColumnHeaders(),
        const SizedBox(height: 16),
        _buildPairs(),
        const SizedBox(height: 24),
        _buildControlButtons(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drag & Drop Pairs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create pairs by adding drag items and their corresponding drop targets',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildColumnHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'Drag Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Text(
              'Drop Targets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPairs() {
    int maxLength =
        dragItemControllers.length > dropTargetControllers.length
            ? dragItemControllers.length
            : dropTargetControllers.length;

    return Column(
      children: List.generate(
        maxLength,
        (index) => DragDropPair(
          index: index,
          dragController:
              index < dragItemControllers.length
                  ? dragItemControllers[index]
                  : null,
          dropController:
              index < dropTargetControllers.length
                  ? dropTargetControllers[index]
                  : null,
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    if (isLocked) return const SizedBox.shrink();

    return Row(
      children: [
        // Add Pair Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLocked ? null : onAddPair,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Add Pair',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Remove Pair Button
        if (dragItemControllers.length > 1 || dropTargetControllers.length > 1)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLocked ? null : onRemovePair,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove, size: 20, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Remove Pair',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
