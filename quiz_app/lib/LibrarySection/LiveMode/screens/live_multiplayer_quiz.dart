import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_results.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/leaderboard_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';

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

    if (currentQuestion == null) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final options = List<String>.from(currentQuestion['options'] ?? []);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: ReconnectionOverlay(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: gameState.timeRemaining / 30.0,
                                backgroundColor: Colors.grey[700],
                                color:
                                    gameState.timeRemaining < 10
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
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
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Question Panel
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          currentQuestion['question'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Options
                Expanded(
                  child: ListView.separated(
                    itemCount: options.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      // final isCorrect = gameState.correctAnswer == option; // Unused for now

                      return ElevatedButton(
                        onPressed:
                            gameState.hasAnswered
                                ? null
                                : () {
                                  ref
                                      .read(gameProvider.notifier)
                                      .submitAnswer(option);
                                },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Status Message or Leaderboard
                if (gameState.rankings != null)
                  Expanded(
                    child: LeaderboardWidget(
                      rankings: gameState.rankings!,
                      currentUserId: currentUserId ?? '',
                    ),
                  )
                else if (gameState.hasAnswered &&
                    gameState.correctAnswer == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        'Waiting for other players...',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                if (gameState.correctAnswer != null &&
                    gameState.rankings == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        gameState.isCorrect == true ? 'CORRECT!' : 'INCORRECT',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              gameState.isCorrect == true
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ),

                // Host Controls
                if (ref.watch(sessionProvider)?.hostId == currentUserId)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
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
                                      Navigator.pop(context); // Close dialog
                                      ref
                                          .read(sessionProvider.notifier)
                                          .endQuiz();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('END NOW'),
                                  ),
                                ],
                              ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'END QUIZ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
