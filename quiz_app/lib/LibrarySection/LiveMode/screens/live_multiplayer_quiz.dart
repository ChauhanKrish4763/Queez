import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_results.dart';
import 'package:quiz_app/LibrarySection/LiveMode/utils/question_type_handler.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/question_text_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';

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
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Compact header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.quiz,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'QUEEZ',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      // Points Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC107), Color(0xFFFFB300)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${gameState.currentScore}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress indicator
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${gameState.questionIndex + 1} of ${gameState.totalQuestions}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Leaderboard button for participants
                          if (!isHost)
                            GestureDetector(
                              onTap: () => _showLeaderboardBottomSheet(context, ref),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.leaderboard, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ranks',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (gameState.questionIndex + 1) / gameState.totalQuestions,
                          backgroundColor: Colors.grey[200],
                          color: AppColors.primary,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Divider
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 1,
                  color: Colors.grey.shade200,
                ),
              ),

              // Question content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question Text Widget
                      QuestionTextWidget(
                        questionText: currentQuestion['question'] ?? '',
                        imageUrl: currentQuestion['imageUrl'],
                      ),
                      const SizedBox(height: 20),

                      // Question UI based on question type
                      QuestionTypeHandler.buildQuestionUI(
                        question: currentQuestion,
                        onAnswerSelected: (answer) {
                          debugPrint('🎮 QUIZ_SCREEN - Answer selected: $answer');
                          ref.read(gameProvider.notifier).submitAnswer(answer);
                        },
                        onNextQuestion: () {
                          debugPrint('🎮 QUIZ_SCREEN - Next question requested');
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
                        Container(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                        const SizedBox(height: 16),
                        
                        // Status message
                        if (gameState.hasAnswered && gameState.correctAnswer == null)
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
                            gameState.questionIndex + 1 < gameState.totalQuestions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ref.read(webSocketServiceProvider).sendMessage('next_question', {});
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('End Quiz?'),
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
                                        Navigator.pop(context);
                                        ref.read(sessionProvider.notifier).endQuiz();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFFE53935),
                                      ),
                                      child: const Text('END NOW'),
                                    ),
                                  ],
                                ),
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
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaderboardBottomSheet(BuildContext context, WidgetRef ref) {
    // Request fresh leaderboard data from backend
    ref.read(gameProvider.notifier).requestLeaderboard();
    debugPrint('🏆 QUIZ_SCREEN - Requested leaderboard, showing bottom sheet');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final gameState = ref.watch(gameProvider);
          final currentUserId = ref.watch(currentUserProvider);
          final rankings = gameState.rankings ?? [];
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: AppColors.background,
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.leaderboard, color: AppColors.primary, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Live Leaderboard',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                        iconSize: 22,
                      ),
                    ],
                  ),
                ),
                
                // Column headers
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 44), // Space for rank
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Player',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 70,
                        child: Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        width: 70,
                        child: Text(
                          'Points',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Leaderboard content
                Expanded(
                  child: rankings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading leaderboard...',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: rankings.length,
                          itemBuilder: (context, index) {
                            final entry = rankings[index];
                            final isCurrentUser = entry['user_id'] == currentUserId;
                            final rank = index + 1;
                            final answeredCount = entry['answered_count'] ?? 0;
                            final totalQuestions = entry['total_questions'] ?? gameState.totalQuestions;

                            // Top 3 get medal styling
                            Color? medalColor;
                            if (rank == 1) {
                              medalColor = const Color(0xFFFFD700); // Gold
                            } else if (rank == 2) {
                              medalColor = const Color(0xFFC0C0C0); // Silver
                            } else if (rank == 3) {
                              medalColor = const Color(0xFFCD7F32); // Bronze
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: isCurrentUser
                                    ? Border.all(color: AppColors.primary, width: 2)
                                    : Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  // Rank badge with medal for top 3
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: medalColor?.withValues(alpha: 0.2) ?? Colors.grey.shade100,
                                      border: Border.all(
                                        color: medalColor ?? Colors.grey.shade300,
                                        width: medalColor != null ? 2 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: medalColor != null
                                          ? Icon(Icons.emoji_events, color: medalColor, size: 18)
                                          : Text(
                                              '$rank',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Username
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry['username'] ?? 'Unknown',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (isCurrentUser)
                                          Text(
                                            'You',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Question progress
                                  SizedBox(
                                    width: 70,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Q$answeredCount/$totalQuestions',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(3),
                                          child: LinearProgressIndicator(
                                            value: totalQuestions > 0 ? answeredCount / totalQuestions : 0,
                                            backgroundColor: Colors.grey.shade200,
                                            color: AppColors.primary,
                                            minHeight: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Score
                                  Container(
                                    width: 70,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: medalColor?.withValues(alpha: 0.15) ?? AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${entry['score'] ?? 0}',
                                      style: TextStyle(
                                        color: medalColor ?? AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
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
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(gameProvider.notifier).requestLeaderboard();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
