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
    Key? key,
    required this.dragItemControllers,
    required this.dropTargetControllers,
    required this.onAddPair,
    required this.onRemovePair,
    this.isLocked = false,
  }) : super(key: key);

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
    int maxLength = dragItemControllers.length > dropTargetControllers.length
        ? dragItemControllers.length
        : dropTargetControllers.length;

    return Column(
      children: List.generate(
        maxLength,
        (index) => DragDropPair(
          index: index,
          dragController: index < dragItemControllers.length
              ? dragItemControllers[index]
              : null,
          dropController: index < dropTargetControllers.length
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
        ElevatedButton.icon(
          onPressed: isLocked ? null : onAddPair,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Pair'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (dragItemControllers.length > 1 || dropTargetControllers.length > 1)
          ElevatedButton.icon(
            onPressed: isLocked ? null : onRemovePair,
            icon: const Icon(Icons.remove, size: 18),
            label: const Text('Remove Pair'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }
}
