import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/host_leaderboard_panel.dart';

class LiveHostView extends ConsumerWidget {
  final String sessionCode;

  const LiveHostView({super.key, required this.sessionCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final sessionState = ref.watch(sessionProvider);
    final rankings = gameState.rankings ?? [];
    final totalQuestions = sessionState?.totalQuestions ?? 0;
    final participantCount = rankings.length;
    
    // Calculate average score across all participants
    final averageScore = rankings.isEmpty
        ? 0.0
        : rankings.fold<double>(
            0.0,
            (sum, participant) => sum + (participant['score'] ?? 0),
          ) / participantCount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Host Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(QuizSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Session Code Display with copy button
              _buildSessionCodeCard(context),
              SizedBox(height: QuizSpacing.lg),

              // Enhanced Host Leaderboard Panel
              Expanded(
                child: HostLeaderboardPanel(
                  rankings: rankings,
                  answerDistribution: gameState.answerDistribution,
                  questionIndex: gameState.questionIndex + 1, // 1-indexed
                  totalQuestions: totalQuestions,
                  participantCount: participantCount,
                  averageScore: averageScore,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the session code card with copy functionality
  Widget _buildSessionCodeCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(QuizSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SESSION CODE',
                style: TextStyle(
                  color: QuizColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              // Copy button
              IconButton(
                icon: Icon(
                  Icons.copy,
                  color: QuizColors.info,
                  size: 20,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: sessionCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Session code copied to clipboard'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: QuizColors.correct,
                    ),
                  );
                },
                tooltip: 'Copy session code',
              ),
            ],
          ),
          SizedBox(height: QuizSpacing.sm),
          Text(
            sessionCode,
            style: TextStyle(
              fontSize: 48,
              letterSpacing: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
