import 'package:flutter/material.dart';
import '../models/question.dart';
import '../widgets/question_card.dart';
import '../widgets/question_navigation.dart';
import 'package:quiz_app/utils/color.dart';

class QuizQuestions extends StatefulWidget {
  const QuizQuestions({Key? key}) : super(key: key);

  @override
  State<QuizQuestions> createState() => _QuizQuestionsState();
}

class _QuizQuestionsState extends State<QuizQuestions> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  bool isNavigationExpanded = false;

  @override
  void initState() {
    super.initState();
    _addNewQuestion();
  }

  void _addNewQuestion() {
    setState(() {
      questions.add(Question(id: DateTime.now().millisecondsSinceEpoch.toString()));
      currentQuestionIndex = questions.length - 1;
    });
  }

  void _updateQuestion(Question updatedQuestion) {
    int index = questions.indexWhere((q) => q.id == updatedQuestion.id);
    if (index != -1) {
      questions[index] = updatedQuestion;
    }
  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      setState(() {
        currentQuestionIndex = index;
      });
    }
  }

  void _toggleNavigationMode() {
    setState(() {
      isNavigationExpanded = !isNavigationExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Create Quiz Questions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: questions.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey('question_${questions[currentQuestionIndex].id}'),
                    child: QuestionCard(
                      key: ValueKey('card_${questions[currentQuestionIndex].id}'),
                      question: questions[currentQuestionIndex],
                      onQuestionUpdated: _updateQuestion,
                    ),
                  ),
                ),
                QuestionNavigation(
                  currentIndex: currentQuestionIndex,
                  totalQuestions: questions.length,
                  onIndexChanged: _navigateToQuestion,
                  onAddQuestion: _addNewQuestion,
                  isExpanded: isNavigationExpanded,
                  onToggleExpanded: _toggleNavigationMode,
                ),
              ],
            ),
    );
  }
}