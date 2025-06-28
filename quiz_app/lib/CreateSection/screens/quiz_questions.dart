import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/services/quiz_cache_manager.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/LibrarySection/screens/library_page.dart';
import '../models/question.dart';
import '../widgets/question_card/question_card.dart';
import '../widgets/question_navigation.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';

class QuizQuestions extends StatefulWidget {
  final List<Question>? questions;

  const QuizQuestions({Key? key, this.questions}) : super(key: key);
  @override
  State<QuizQuestions> createState() => _QuizQuestionsState();
}

class _QuizQuestionsState extends State<QuizQuestions> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  bool isNavigationExpanded = false;
  bool _isLocked = false;


  @override
  void initState() {
    super.initState();
    if (widget.questions != null && widget.questions!.isNotEmpty) {
      questions = List.from(widget.questions!);
      _isLocked = true;
      currentQuestionIndex = 0;
    } else {
      _addNewQuestion();
    }
  }

  void _addNewQuestion() {
    setState(() {
      questions.add(
        Question(id: DateTime.now().millisecondsSinceEpoch.toString()),
      );
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
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
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
              onTap: _saveQuiz,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
      body:
          questions.isEmpty
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  key: ValueKey('emptyQuestionsLoadingIndicator'),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: ValueKey(
                        'question_${questions[currentQuestionIndex].id}',
                      ),
                      child: QuestionCard(
                        key: ValueKey(
                          'card_${questions[currentQuestionIndex].id}',
                        ),
                        question: questions[currentQuestionIndex],
                        onQuestionUpdated: _updateQuestion,
                        isLocked: _isLocked,
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
                    isLocked: _isLocked,
                  ),
                ],
              ),
    );
  }

  Future<void> _saveQuiz() async {
    print('Starting _saveQuiz');
    try {
      // Update questions in cache
      print('Updating questions in cache');
      QuizCacheManager.instance.updateQuestions(questions);

      // Get the complete quiz from cache
      print('Retrieving quiz from cache');
      final quiz = QuizCacheManager.instance.currentQuiz;

      if (quiz == null) {
        throw Exception('No quiz details found');
      }

      // Save to backend with timeout
      print('Saving quiz to backend');
      String quizId;

      // Call createQuiz() for new quiz
      quizId = await QuizService.createQuiz(quiz).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timed out'),
      );

      print('Quiz saved with ID: $quizId');

      // Show success dialog
      if (mounted) {
        await QuizSavedDialog.show(
          context,
          title: 'Success!',
          message: 'Your quiz has been saved successfully and is ready to use!',
          onDismiss: () {
            print('Success dialog dismissed');
            QuizCacheManager.instance.clearCache();
            print('Cache cleared');
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (bottomNavbarKey.currentState != null) {
                  bottomNavbarKey.currentState!.setIndex(1);
                }
                LibraryPage.reloadItems();
              });
            }
          },
        );
        print('Success dialog shown');
      }
    } catch (e, stackTrace) {
      print('Error in _saveQuiz: $e\n$stackTrace');
      // Show error dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Error'),
                  ],
                ),
                content: Text('Failed to save quiz: $e'),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(dialogContext).pop();
                        print('Error dialog dismissed');
                      }
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }
}
