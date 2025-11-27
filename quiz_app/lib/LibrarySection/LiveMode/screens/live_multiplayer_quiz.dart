import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_results.dart';
import 'package:quiz_app/LibrarySection/LiveMode/utils/question_type_handler.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/question_text_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';

class LiveMultiplayerQuiz extends ConsumerStatefulWidget {
  const LiveMultiplayerQuiz({super.key});

  @override
  ConsumerState<LiveMultiplayerQuiz> createState() =>
      _LiveMultiplayerQuizState();
}

class _LiveMultiplayerQuizState extends ConsumerState<LiveMultiplayerQuiz> {
  bool _hasNavigatedToResults = false;

  void _navigateToResults() {
    if (_hasNavigatedToResults) {
      debugPrint('🏁 QUIZ_SCREEN - Already navigated to results, skipping');
      return;
    }
    
    _hasNavigatedToResults = true;
    debugPrint('🏁 QUIZ_SCREEN - Navigating to results');
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LiveMultiplayerResults(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (next != null && next.status == 'completed') {
        debugPrint('🏁 QUIZ_SCREEN - Session completed');
        _navigateToResults();
      }
    });

    ref.listen(gameProvider, (previous, next) {
      debugPrint(
        '🎮 UI - Game state changed, currentQuestion: ${next.currentQuestion != null ? "SET" : "NULL"}',
      );

      // Check if quiz completed message received
      if (previous?.currentQuestion != null &&
          next.currentQuestion == null &&
          next.rankings != null &&
          next.rankings!.isNotEmpty) {
        debugPrint('🏁 QUIZ_SCREEN - Quiz completed message received');
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToResults();
        });
      }

      // Check if last question answered - navigate to results
      debugPrint(
        '🔍 LAST_Q_CHECK - hasAnswered: ${next.hasAnswered}, rankings: ${next.rankings != null ? "YES (${next.rankings!.length})" : "NULL"}, questionIndex: ${next.questionIndex}, totalQuestions: ${next.totalQuestions}, showingLeaderboard: ${next.showingLeaderboard}',
      );

      if (next.hasAnswered &&
          next.rankings != null &&
          next.rankings!.isNotEmpty &&
          next.questionIndex + 1 >= next.totalQuestions &&
          !next.showingLeaderboard) {
        debugPrint(
          '🏁 QUIZ_SCREEN - ✅ LAST QUESTION DETECTED! Navigating to results in 2s...',
        );
        debugPrint(
          '🏁 QUIZ_SCREEN - Details: index=${next.questionIndex}, total=${next.totalQuestions}, calc=${next.questionIndex + 1}',
        );
        Future.delayed(const Duration(milliseconds: 2000), () {
          debugPrint('🏁 QUIZ_SCREEN - NOW NAVIGATING TO RESULTS!');
          _navigateToResults();
        });
      }
    });

    ref.listen(sessionProvider.notifier.select((n) => n.errorStream), (
      previous,
      next,
    ) {
      next.listen((error) {
        if (context.mounted) {
          AppDialog.show(
            context: context,
            title: 'Error',
            content: error,
            primaryActionText: 'OK',
            primaryActionCallback: () => Navigator.pop(context),
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
              CircularProgressIndicator(color: AppColors.primary),
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
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Sub-header with Question counter, Ranks button, Points
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Question counter
                      Text(
                        'Question ${gameState.questionIndex + 1} of ${gameState.totalQuestions}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Right side: Ranks button + Points
                      Row(
                        children: [
                          // Ranks button (only for participants)
                          if (!isHost)
                            GestureDetector(
                              onTap:
                                  () =>
                                      _showLeaderboardBottomSheet(context, ref),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.primaryLight,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.bar_chart,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ranks',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (!isHost) const SizedBox(width: 12),
                          // Points Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: AppColors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${gameState.currentScore}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Progress Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value:
                          (gameState.questionIndex + 1) /
                          gameState.totalQuestions,
                      backgroundColor: AppColors.primaryLighter,
                      color: AppColors.primary,
                      minHeight: 6,
                    ),
                  ),
                ),
              ),

              // Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Text(
                    currentQuestion['question'] ?? 'Match the capitals',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Question content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question Text Widget (if there's an image)
                      if (currentQuestion['imageUrl'] != null)
                        QuestionTextWidget(
                          questionText: currentQuestion['question'] ?? '',
                          imageUrl: currentQuestion['imageUrl'],
                        ),
                      if (currentQuestion['imageUrl'] != null)
                        const SizedBox(height: 20),

                      // Question UI based on question type
                      QuestionTypeHandler.buildQuestionUI(
                        question: currentQuestion,
                        onAnswerSelected: (answer) {
                          debugPrint(
                            '🎮 QUIZ_SCREEN - Answer selected: $answer',
                          );
                          ref.read(gameProvider.notifier).submitAnswer(answer);
                        },
                        onNextQuestion: () {
                          debugPrint(
                            '🎮 QUIZ_SCREEN - Next question requested',
                          );
                          ref.read(gameProvider.notifier).requestNextQuestion();
                        },
                        hasAnswered: gameState.hasAnswered,
                        selectedAnswer: gameState.selectedAnswer,
                        isCorrect: gameState.isCorrect,
                        correctAnswer: gameState.correctAnswer,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Host controls section
              if (isHost)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Divider before host controls
                        Container(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 16),

                        // Status message
                        if (gameState.hasAnswered &&
                            gameState.correctAnswer == null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Waiting for other players...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                          ),

                        // Next Question button (not on last question)
                        if (gameState.hasAnswered &&
                            gameState.rankings != null &&
                            gameState.questionIndex + 1 <
                                gameState.totalQuestions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(webSocketServiceProvider)
                                      .sendMessage('next_question', {});
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'NEXT QUESTION',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // End Quiz button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              AppDialog.show(
                                context: context,
                                title: 'End Quiz?',
                                content:
                                    'Are you sure you want to end the quiz early? All progress will be saved.',
                                secondaryActionText: 'CANCEL',
                                secondaryActionCallback:
                                    () => Navigator.pop(context),
                                primaryActionText: 'END NOW',
                                primaryActionCallback: () {
                                  Navigator.pop(context);
                                  ref.read(sessionProvider.notifier).endQuiz();
                                },
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE53935)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'END QUIZ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaderboardBottomSheet(BuildContext context, WidgetRef ref) {
    ref.read(gameProvider.notifier).requestLeaderboard();
    debugPrint('🏆 QUIZ_SCREEN - Requested leaderboard, showing bottom sheet');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Consumer(
            builder: (context, ref, child) {
              final gameState = ref.watch(gameProvider);
              ref.watch(currentUserProvider);
              final rankings = gameState.rankings ?? [];

              return Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Live Leaderboard',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.close,
                              size: 24,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Leaderboard content
                    Expanded(
                      child:
                          rankings.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: rankings.length,
                                itemBuilder: (context, index) {
                                  final entry = rankings[index];
                                  final rank = index + 1;
                                  final answeredCount =
                                      entry['answered_count'] ?? 0;
                                  final totalQuestions =
                                      entry['total_questions'] ??
                                      gameState.totalQuestions;
                                  final score = entry['score'] ?? 0;
                                  final username =
                                      entry['username'] ?? 'Unknown';

                                  // Medal colors for top 3
                                  Color? medalColor;
                                  if (rank == 1) {
                                    medalColor = const Color(
                                      0xFFFFD700,
                                    ); // Gold
                                  } else if (rank == 2) {
                                    medalColor = const Color(
                                      0xFFC0C0C0,
                                    ); // Silver
                                  } else if (rank == 3) {
                                    medalColor = const Color(
                                      0xFFCD7F32,
                                    ); // Bronze
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        // Rank badge
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                medalColor ??
                                                AppColors.primaryLight,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$rank',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color:
                                                    medalColor != null
                                                        ? AppColors.white
                                                        : AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Username and progress
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                username,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                'Q$answeredCount/$totalQuestions',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Score
                                        Text(
                                          '$score',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),

                    // Refresh button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(gameProvider.notifier)
                                .requestLeaderboard();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text(
                            'Refresh',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
