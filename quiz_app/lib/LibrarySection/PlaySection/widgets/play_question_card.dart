import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/LibrarySection/PlaySection/widgets/question_types/drag_drop_options.dart';
import 'package:quiz_app/LibrarySection/PlaySection/widgets/question_types/mcq_options.dart';
import 'package:quiz_app/LibrarySection/PlaySection/widgets/question_types/true_false_options.dart';
import 'package:quiz_app/utils/color.dart';

class PlayQuestionCard extends StatelessWidget {
  final Question question;
  final dynamic userAnswer;
  final ValueChanged<dynamic> onAnswerSelected;
  final ScrollController? scrollController;

  const PlayQuestionCard({
    super.key,
    required this.question,
    required this.userAnswer,
    required this.onAnswerSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Question Text
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.surface),
          const SizedBox(height: 24),

          // Options based on question type
          _buildOptionsWidget(),
        ],
      ),
    );
  }

  Widget _buildOptionsWidget() {
    switch (question.type) {
      case QuestionType.singleMcq:
        return McqOptions(
          question: question,
          userAnswer: userAnswer,
          onAnswerSelected: (answer) {
            // Prevent changing answer after selection
            if (userAnswer == null) {
              onAnswerSelected(answer);
            }
          },
        );
      case QuestionType.multiMcq:
        return McqOptions(
          question: question,
          userAnswer: userAnswer,
          isMultiSelect: true,
          onAnswerSelected: onAnswerSelected,
        );
      case QuestionType.trueFalse:
        return TrueFalseOptions(
          question: question,
          userAnswer: userAnswer,
          onAnswerSelected: (answer) {
            if (userAnswer == null) {
              onAnswerSelected(answer);
            }
          },
        );
      case QuestionType.dragAndDrop:
        return DragDropOptions(
          question: question,
          userAnswer: userAnswer,
          onAnswerSelected: onAnswerSelected,
          scrollController: scrollController,
        );
    }
  }
}
