import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_results.dart';
import 'package:quiz_app/LibrarySection/LiveMode/utils/question_type_handler.dart';
import 'package:quiz_app/LibrarySection/LiveMode/utils/transition_animation_controller.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/answer_feedback_overlay.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/correct_answer_highlight.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/leaderboard_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/participant_score_card.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/question_text_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

class LiveMultiplayerQuiz extends ConsumerStatefulWidget {
  const LiveMultiplayerQuiz({super.key});

  @override
  ConsumerState<LiveMultiplayerQuiz> createState() =>
      _LiveMultiplayerQuizState();
}

class _LiveMultiplayerQuizState extends ConsumerState<LiveMultiplayerQuiz> {
  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (next != null && next.status == 'completed') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LiveMultiplayerResults(),
          ),
        );
      }
    });
    ref.listen(gameProvider, (previous, next) {
      debugPrint(
        '🎮 UI - Game state changed, currentQuestion: ${next.currentQuestion != null ? "SET" : "NULL"}',
      );
    });

    ref.listen(sessionProvider.notifier.select((n) => n.errorStream), (
      previous,
      next,
    ) {
      next.listen((error) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('ERROR'),
                  content: Text(error),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      });
    });

    final gameState = ref.watch(gameProvider);
    final currentQuestion = gameState.currentQuestion;
    final currentUserId = ref.watch(currentUserProvider);
    final isHost = ref.watch(sessionProvider)?.hostId == currentUserId;
    debugPrint(
      '🎮 UI - Building with currentQuestion: ${currentQuestion != null ? "SET" : "NULL"}',
    );

    if (currentQuestion == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading question...',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ReconnectionOverlay(
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header: Timer and Question Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color:
                                    gameState.timeRemaining < 10
                                        ? AppColors.error
                                        : AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: gameState.timeRemaining / 30.0,
                                    backgroundColor: Colors.grey[300],
                                    color:
                                        gameState.timeRemaining < 10
                                            ? AppColors.error
                                            : AppColors.primary,
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          'Q ${gameState.questionIndex + 1} / ${gameState.totalQuestions}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Question Text Widget
                    QuestionTextWidget(
                      questionText: currentQuestion['question'] ?? '',
                      imageUrl: currentQuestion['imageUrl'],
                    ),
                    const SizedBox(height: 24),

                    // Question UI based on question type
                    Expanded(
                      child: QuestionTypeHandler.buildQuestionUI(
                        question: currentQuestion,
                        onAnswerSelected: (answer) {
                          ref.read(gameProvider.notifier).submitAnswer(answer);
                        },
                        hasAnswered: gameState.hasAnswered,
                        selectedAnswer: gameState.selectedAnswer,
                        isCorrect: gameState.isCorrect,
                        correctAnswer: gameState.correctAnswer,
                      ),
                    ),

                    // Status Message, Leaderboard (Host only), or Participant Score Card
                    if (gameState.rankings != null)
                      // Show leaderboard only to host
                      if (isHost)
                        Expanded(
                          child: LeaderboardWidget(
                            rankings: gameState.rankings!,
                            currentUserId: currentUserId ?? '',
                          ),
                        )
                      else
                        // Show participant score card to non-host participants
                        Padding(
                          padding: const EdgeInsets.only(top: QuizSpacing.md),
                          child: ParticipantScoreCard(
                            currentScore: gameState.currentScore,
                            pointsEarned: gameState.pointsEarned,
                            lastAnswerCorrect: gameState.isCorrect,
                          ),
                        )
                    else if (gameState.hasAnswered &&
                        gameState.correctAnswer == null)
                      Padding(
                        padding: const EdgeInsets.only(top: QuizSpacing.md),
                        child: Center(
                          child: Text(
                            // Check if single player or multiplayer
                            (ref.watch(sessionProvider)?.participantCount ??
                                        0) >
                                    1
                                ? 'Waiting for other players...'
                                : 'Checking answer...',
                            style: TextStyle(
                              color: QuizColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                    if (gameState.correctAnswer != null &&
                        gameState.rankings == null)
                      Padding(
                        padding: const EdgeInsets.only(top: QuizSpacing.md),
                        child: Center(
                          child: Text(
                            gameState.isCorrect == true
                                ? 'CORRECT!'
                                : 'INCORRECT',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  gameState.isCorrect == true
                                      ? QuizColors.correct
                                      : QuizColors.incorrect,
                            ),
                          ),
                        ),
                      ),

                    // ✅ HOST CONTROLS - NEXT QUESTION BUTTON
                    if (isHost &&
                        gameState.hasAnswered &&
                        gameState.rankings != null)
                      Padding(
                        padding: const EdgeInsets.only(top: QuizSpacing.lg),
                        child: ElevatedButton(
                          onPressed: () {
                            // Send next_question message via WebSocket
                            ref
                                .read(webSocketServiceProvider)
                                .sendMessage('next_question', {});
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: QuizSpacing.md,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                QuizBorderRadius.md,
                              ),
                            ),
                          ),
                          child: const Text(
                            'NEXT QUESTION',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    // HOST CONTROLS - END QUIZ BUTTON
                    if (isHost)
                      Padding(
                        padding: const EdgeInsets.only(top: QuizSpacing.md),
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('END QUIZ?'),
                                    content: const Text(
                                      'Are you sure you want to end the quiz early? All progress will be saved.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            context,
                                          ); // Close dialog
                                          ref
                                              .read(sessionProvider.notifier)
                                              .endQuiz();
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: QuizColors.incorrect,
                                        ),
                                        child: const Text('END NOW'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: QuizSpacing.md,
                            ),
                            side: BorderSide(color: QuizColors.incorrect),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                QuizBorderRadius.md,
                              ),
                            ),
                          ),
                          child: Text(
                            'END QUIZ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: QuizColors.incorrect,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Answer Feedback Overlay - shown when showingFeedback is true
            if (gameState.showingFeedback &&
                gameState.isCorrect != null &&
                gameState.pointsEarned != null)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: AnswerFeedbackOverlay(
                    isCorrect: gameState.isCorrect!,
                    pointsEarned: gameState.pointsEarned!,
                    onComplete: () {
                      // Hide feedback and show correct answer highlight
                      ref
                          .read(gameProvider.notifier)
                          .showCorrectAnswerHighlight();
                    },
                  ),
                ),
              ),

            // Correct Answer Highlight - shown after feedback is dismissed
            if (gameState.showingCorrectAnswer &&
                gameState.correctAnswer != null)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(QuizSpacing.lg),
                    child: CorrectAnswerHighlight(
                      correctAnswer: gameState.correctAnswer,
                      countdown: 2,
                      onCountdownComplete: () {
                        // Use transition animation when advancing to next question
                        TransitionAnimationController.transitionToNextQuestion(
                          context: context,
                          onComplete: () {
                            // Hide correct answer highlight and allow progression to next question
                            ref
                                .read(gameProvider.notifier)
                                .hideCorrectAnswerHighlight();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
