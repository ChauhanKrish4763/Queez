import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/LibrarySection/PlaySection/models/quiz_attempt.dart';
import 'package:quiz_app/LibrarySection/PlaySection/screens/quiz_results_screen.dart';
import 'package:quiz_app/LibrarySection/PlaySection/widgets/play_question_card.dart';
import 'package:quiz_app/LibrarySection/PlaySection/widgets/progress_timer_bar.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizLibraryItem quizItem;
  final List<Question>? preloadedQuestions;

  const QuizPlayScreen({
    super.key,
    required this.quizItem,
    this.preloadedQuestions,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with TickerProviderStateMixin {
  QuizAttempt? _quizAttempt;
  int _currentIndex = 0;

  late AnimationController _progressController;
  late AnimationController _cardAnimationController;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Use preloaded questions if available, otherwise fetch
    if (widget.preloadedQuestions != null &&
        widget.preloadedQuestions!.isNotEmpty) {
      _quizAttempt = QuizAttempt(questions: widget.preloadedQuestions!);
      _progressController.animateTo(1 / widget.preloadedQuestions!.length);
      _cardAnimationController.forward();
    } else {
      _fetchQuestions();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Question>> _fetchQuestions() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated");
      }
      final questions = await QuizService.fetchQuestionsByQuizId(
        widget.quizItem.id,
        userId,
      );
      if (questions.isEmpty) {
        throw Exception("This quiz has no questions.");
      }
      setState(() {
        _quizAttempt = QuizAttempt(questions: questions);
        _progressController.animateTo(1 / questions.length);
        _cardAnimationController.forward();
      });
      return questions;
    } catch (e) {
      // Show error in snackbar instead of state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      }
      return [];
    }
  }

  void _onAnswerSelected(dynamic answer) {
    if (_quizAttempt == null) return;

    setState(() {
      _quizAttempt!.recordAnswer(_currentIndex, answer);
    });

    // Short delay to show feedback before moving to the next question
    Future.delayed(const Duration(milliseconds: 800), () {
      _goToNextQuestion();
    });
  }

  void _goToNextQuestion() {
    if (_quizAttempt == null) return;

    if (_currentIndex < _quizAttempt!.questions.length - 1) {
      _cardAnimationController.reverse().then((_) {
        setState(() {
          _currentIndex++;
          _progressController.animateTo(
            (_currentIndex + 1) / _quizAttempt!.questions.length,
          );
        });
        _cardAnimationController.forward();
      });
    } else {
      // Quiz finished, navigate to results
      _quizAttempt!.calculateScore();
      Navigator.pushReplacement(
        context,
        customRoute(
          QuizResultsScreen(
            quizItem: widget.quizItem,
            quizAttempt: _quizAttempt!,
          ),
          AnimationType.slideUp,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.quizItem.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_quizAttempt == null || _quizAttempt!.questions.isEmpty) {
      return const Center(
        child: Text(
          'No questions found for this quiz.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    final question = _quizAttempt!.questions[_currentIndex];
    final userAnswer = _quizAttempt!.answers[_currentIndex];

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: ProgressTimerBar(
              controller: _progressController,
              currentIndex: _currentIndex,
              total: _quizAttempt!.questions.length,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return SlideTransition(position: _slideAnimation, child: child);
            },
            child: PlayQuestionCard(
              key: ValueKey<String>(question.id),
              question: question,
              userAnswer: userAnswer,
              onAnswerSelected: _onAnswerSelected,
              scrollController: _scrollController,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
