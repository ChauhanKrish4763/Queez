import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/host_leaderboard_panel.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_results.dart';

class LiveHostView extends ConsumerStatefulWidget {
  final String sessionCode;

  const LiveHostView({super.key, required this.sessionCode});

  @override
  ConsumerState<LiveHostView> createState() => _LiveHostViewState();
}

class _LiveHostViewState extends ConsumerState<LiveHostView> {
  @override
  Widget build(BuildContext context) {
    // Listen for quiz completion and navigate to results
    ref.listen(sessionProvider, (previous, next) {
      if (next != null && next.status == 'completed') {
        debugPrint('🏁 HOST_VIEW - Session completed, navigating to results');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LiveMultiplayerResults(),
          ),
        );
      }
    });

    ref.listen(gameProvider, (previous, next) {
      // Check if quiz completed message received (quiz_ended or quiz_completed)
      if (previous?.currentQuestion != null && 
          next.currentQuestion == null && 
          next.rankings != null && 
          next.rankings!.isNotEmpty) {
        debugPrint('🏁 HOST_VIEW - Quiz completed, navigating to results');
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
    });

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Host Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Session Code Display with copy button
              _buildSessionCodeCard(context),
              const SizedBox(height: 24),

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SESSION CODE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              // Copy button
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.sessionCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session code copied to clipboard'),
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                tooltip: 'Copy session code',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.sessionCode,
            style: const TextStyle(
              fontSize: 48,
              letterSpacing: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
