import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_results.dart';
import 'package:quiz_app/LibrarySection/LiveMode/utils/question_type_handler.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/podium_widget.dart';
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
        debugPrint('🏁 QUIZ_SCREEN - Session completed, navigating to results');
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
      
      // Check if quiz completed message received
      if (previous?.currentQuestion != null && next.currentQuestion == null && next.rankings != null && next.rankings!.isNotEmpty) {
        debugPrint('🏁 QUIZ_SCREEN - Quiz completed, navigating to results');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LiveMultiplayerResults(),
              ),
            );
          }
        });
      }
      
      // Check if last question answered - navigate to results
      debugPrint('🔍 LAST_Q_CHECK - hasAnswered: ${next.hasAnswered}, rankings: ${next.rankings != null ? "YES (${next.rankings!.length})" : "NULL"}, questionIndex: ${next.questionIndex}, totalQuestions: ${next.totalQuestions}, showingLeaderboard: ${next.showingLeaderboard}');
      
      if (next.hasAnswered && 
          next.rankings != null && 
          next.rankings!.isNotEmpty &&
          next.questionIndex + 1 >= next.totalQuestions &&
          !next.showingLeaderboard) {
        debugPrint('🏁 QUIZ_SCREEN - ✅ LAST QUESTION DETECTED! Navigating to results in 2s...');
        debugPrint('🏁 QUIZ_SCREEN - Details: index=${next.questionIndex}, total=${next.totalQuestions}, calc=${next.questionIndex + 1}');
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (context.mounted) {
            debugPrint('🏁 QUIZ_SCREEN - NOW NAVIGATING TO RESULTS!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LiveMultiplayerResults(),
              ),
            );
          } else {
            debugPrint('❌ QUIZ_SCREEN - Context not mounted, cannot navigate');
          }
        });
      } else {
        if (next.hasAnswered && next.rankings != null && next.rankings!.isNotEmpty) {
          debugPrint('❌ LAST_Q_CHECK - Not last question yet or showing leaderboard');
        }
      }
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
                    // Header: Logo and Points Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.quiz,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'QUEEZ',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        // Points Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFC107), Color(0xFFFFB300)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFC107).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${gameState.currentScore}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q ${gameState.questionIndex + 1}/${gameState.totalQuestions}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (gameState.questionIndex + 1) / gameState.totalQuestions,
                            backgroundColor: Colors.grey[300],
                            color: AppColors.primary,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Scrollable Content Area
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question Text Widget
                            QuestionTextWidget(
                              questionText: currentQuestion['question'] ?? '',
                              imageUrl: currentQuestion['imageUrl'],
                            ),
                            const SizedBox(height: 24),

                            // Question UI based on question type
                            QuestionTypeHandler.buildQuestionUI(
                              question: currentQuestion,
                              onAnswerSelected: (answer) {
                                ref.read(gameProvider.notifier).submitAnswer(answer);
                              },
                              onNextQuestion: () {
                                ref.read(gameProvider.notifier).requestNextQuestion();
                              },
                              hasAnswered: gameState.hasAnswered,
                              selectedAnswer: gameState.selectedAnswer,
                              isCorrect: gameState.isCorrect,
                              correctAnswer: gameState.correctAnswer,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Show Leaderboard Button - Always Visible
                    if (!isHost)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            _showLeaderboardBottomSheet(context, ref);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Show Leaderboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    // Status Message for Host
                    if (isHost && gameState.hasAnswered && gameState.correctAnswer == null)
                      Padding(
                        padding: const EdgeInsets.only(top: QuizSpacing.md),
                        child: Center(
                          child: Text(
                            'Waiting for other players...',
                            style: TextStyle(
                              color: QuizColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                    // ✅ HOST CONTROLS - NEXT QUESTION BUTTON (NOT on last question)
                    if (isHost &&
                        gameState.hasAnswered &&
                        gameState.rankings != null &&
                        gameState.questionIndex + 1 < gameState.totalQuestions)
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

            // Leaderboard Popup - DISABLED FOR NOW (keeping code for future use)
            // if (gameState.showingLeaderboard &&
            //     gameState.rankings != null &&
            //     gameState.rankings!.isNotEmpty &&
            //     gameState.questionIndex + 1 < gameState.totalQuestions)
            //   LeaderboardPopup(
            //     rankings: gameState.rankings!,
            //     currentUserId: currentUserId ?? '',
            //     displayDuration: 3,
            //     onComplete: () {
            //       debugPrint('🎮 QUIZ_SCREEN - Leaderboard popup completed');
            //       // Hide leaderboard and request next question
            //       ref.read(gameProvider.notifier).hideLeaderboard();
            //       // Auto-request next question for participant
            //       if (!isHost) {
            //         debugPrint('👤 QUIZ_SCREEN - Participant requesting next question');
            //         ref.read(gameProvider.notifier).requestNextQuestion();
            //       } else {
            //         debugPrint('👑 QUIZ_SCREEN - Host waiting for manual next question');
            //       }
            //     },
            //   ),
          ],
        ),
      ),
    );
  }

  void _showLeaderboardBottomSheet(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameProvider);
    final currentUserId = ref.read(currentUserProvider);
    final rankings = gameState.rankings ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
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
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            // Check if all participants have completed current question
            Builder(
              builder: (context) {
                final session = ref.watch(sessionProvider);
                final currentQuestionIndex = gameState.questionIndex;
                final hostId = session?.hostId;
                
                // Filter out host from participants
                final nonHostParticipants = session?.participants.where(
                  (p) => p.userId != hostId
                ).toList() ?? [];
                
                final allParticipantsCompleted = nonHostParticipants.every(
                  (p) => p.answers.length > currentQuestionIndex
                );

                if (!allParticipantsCompleted && nonHostParticipants.isNotEmpty) {
                  final completedCount = nonHostParticipants.where(
                    (p) => p.answers.length > currentQuestionIndex
                  ).length;
                  final totalCount = nonHostParticipants.length;

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Waiting for other players...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completedCount / $totalCount players completed',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Top 3 Podium
                if (rankings.length >= 3) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: PodiumWidget(
                      topThree: rankings.take(3).toList(),
                      currentUserId: currentUserId ?? '',
                    ),
                  );
                } else if (rankings.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: rankings.map((entry) {
                        final isCurrentUser = entry['user_id'] == currentUserId;
                        return Card(
                          elevation: isCurrentUser ? 4 : 2,
                          color: isCurrentUser
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isCurrentUser
                                ? const BorderSide(color: AppColors.primary, width: 2)
                                : BorderSide.none,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: QuizColors.gold.withValues(alpha: 0.2),
                                    border: Border.all(color: QuizColors.gold, width: 2),
                                  ),
                                  child: Icon(
                                    Icons.emoji_events,
                                    color: QuizColors.gold,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    entry['username'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.primary),
                                  ),
                                  child: Text(
                                    '${entry['score']}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Rest of the leaderboard
            if (rankings.length > 3)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: rankings.length - 3,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final actualIndex = index + 3;
                      final entry = rankings[actualIndex];
                      final isCurrentUser = entry['user_id'] == currentUserId;
                      final rank = actualIndex + 1;

                      return Card(
                        elevation: isCurrentUser ? 4 : 2,
                        color: isCurrentUser
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isCurrentUser
                              ? const BorderSide(color: AppColors.primary, width: 2)
                              : BorderSide.none,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Rank
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Text(
                                  '$rank',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Username
                              Expanded(
                                child: Text(
                                  entry['username'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: isCurrentUser
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Score
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary),
                                ),
                                child: Text(
                                  '${entry['score']}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
