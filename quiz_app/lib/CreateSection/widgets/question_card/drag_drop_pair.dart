import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/widgets/custom_text_field.dart';
import 'package:quiz_app/utils/color.dart';

class DragDropPair extends StatelessWidget {
  final int index;
  final TextEditingController? dragController;
  final TextEditingController? dropController;

  const DragDropPair({
    Key? key,
    required this.index,
    this.dragController,
    this.dropController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Drag item field
          Expanded(
            flex: 1,
            child: CustomTextField(
              controller: dragController ?? TextEditingController(),
              hintText: 'Drag item ${index + 1}',
              width: double.infinity,
            ),
          ),

          const SizedBox(width: 24),

          // Drop target field
          Expanded(
            flex: 1,
            child: CustomTextField(
              controller: dropController ?? TextEditingController(),
              hintText: 'Drop target ${index + 1}',
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
