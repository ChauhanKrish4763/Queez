import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Widget that displays question text prominently above answer options
/// Supports optional image display and ensures proper text wrapping
class QuestionTextWidget extends StatelessWidget {
  final String questionText;
  final String? imageUrl;

  const QuestionTextWidget({
    super.key,
    required this.questionText,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(QuizSpacing.lg), // 24px padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg), // 16px rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display image if imageUrl is provided
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(QuizBorderRadius.md), // 12px rounded corners for image
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: QuizSpacing.md), // 16px spacing between image and text
          ],
          // Display question text with proper styling and wrapping
          Text(
            questionText,
            style: QuizTextStyles.questionText,
            softWrap: true, // Ensure text wraps properly
            overflow: TextOverflow.visible, // No truncation
          ),
        ],
      ),
    );
  }
}
