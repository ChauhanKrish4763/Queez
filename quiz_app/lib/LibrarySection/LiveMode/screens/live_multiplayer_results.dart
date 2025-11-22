import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/leaderboard_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/podium_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

class LiveMultiplayerResults extends ConsumerWidget {
  const LiveMultiplayerResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final currentUserId = ref.watch(currentUserProvider);

    // Get rankings from game state
    final rankings = gameState.rankings ?? [];

    if (rankings.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    // Get top 3 for podium
    final topThree = rankings.take(3).toList();

    // Find current user's rank
    final currentUserRank = rankings.indexWhere(
          (r) => r['user_id'] == currentUserId,
        ) +
        1;

    // Congratulations message based on rank
    String congratsMessage = '';
    Color congratsColor = AppColors.textPrimary;

    if (currentUserRank == 1) {
      congratsMessage = '🎉 CHAMPION! You\'re #1! 🎉';
      congratsColor = QuizColors.gold;
    } else if (currentUserRank == 2) {
      congratsMessage = '🥈 Amazing! You\'re 2nd Place! 🥈';
      congratsColor = QuizColors.silver;
    } else if (currentUserRank == 3) {
      congratsMessage = '🥉 Great Job! You\'re 3rd Place! 🥉';
      congratsColor = QuizColors.bronze;
    } else if (currentUserRank > 0) {
      congratsMessage = 'Well Done! You finished #$currentUserRank';
      congratsColor = AppColors.primary;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ReconnectionOverlay(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(QuizSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(QuizSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: QuizColors.gold,
                        size: 64,
                      ),
                      const SizedBox(height: QuizSpacing.md),
                      const Text(
                        'QUIZ COMPLETED!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: QuizSpacing.xl),

                // Congratulations Message (if in top 3)
                if (currentUserRank > 0 && currentUserRank <= 3)
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(QuizSpacing.lg),
                          decoration: BoxDecoration(
                            color: congratsColor.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(QuizBorderRadius.lg),
                            border: Border.all(
                              color: congratsColor,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            congratsMessage,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: congratsColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),

                if (currentUserRank > 0 && currentUserRank <= 3)
                  const SizedBox(height: QuizSpacing.xl),

                // Podium for Top 3
                if (topThree.isNotEmpty)
                  PodiumWidget(
                    topThree: topThree,
                    currentUserId: currentUserId ?? '',
                  ),

                const SizedBox(height: QuizSpacing.xl),

                // Full Leaderboard
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: LeaderboardWidget(
                    rankings: rankings,
                    currentUserId: currentUserId ?? '',
                  ),
                ),

                const SizedBox(height: QuizSpacing.lg),

                // Exit Button
                ElevatedButton(
                  onPressed: () {
                    debugPrint('🏠 RESULTS - Navigating back to home');
                    // Pop all routes and go back to dashboard
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: QuizSpacing.md),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                    ),
                  ),
                  child: const Text(
                    'RETURN TO HOME',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
