import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/leaderboard_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

class LiveMultiplayerResults extends ConsumerWidget {
  const LiveMultiplayerResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final sessionState = ref.watch(sessionProvider);

    if (sessionState == null) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    // Assuming sessionState has final rankings or we get it from gameProvider
    // For now, let's assume sessionState.participants is sorted by score
    // Or better, use a dedicated rankings field if available.
    // The SessionState model has `participants`, but GameState has `rankings`.
    // Let's use participants for now as fallback.

    final rankings =
        sessionState.participants
            .map(
              (p) => {
                'user_id': p.userId,
                'username': p.username,
                'score': p.score,
              },
            )
            .toList();

    // Sort by score descending
    rankings.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    final currentUserId = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: ReconnectionOverlay(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(QuizSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(QuizSpacing.lg),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: QuizColors.gold,
                          size: 64,
                        ),
                        const SizedBox(height: QuizSpacing.md),
                        Text(
                          'QUIZ COMPLETED',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: QuizSpacing.xl),

                // Leaderboard
                Expanded(
                  child: LeaderboardWidget(
                    rankings: rankings,
                    currentUserId: currentUserId ?? '',
                  ),
                ),

                const SizedBox(height: QuizSpacing.lg),

                // Exit Button
                ElevatedButton(
                  onPressed: () {
                    // Pop until we are back at the dashboard or library
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: QuizSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                    ),
                  ),
                  child: const Text(
                    'RETURN TO LIBRARY',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
