import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_results.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/leaderboard_widget.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_background.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_button.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_dialog.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_panel.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_slider.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_transition.dart';

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
          SciFiPageTransition(child: const LiveMultiplayerResults()),
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
                (context) => SciFiDialog(
                  title: 'ERROR',
                  message: error,
                  isDestructive: true,
                  confirmText: 'OK',
                  onConfirm: () {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
          );
        }
      });
    });

    final gameState = ref.watch(gameProvider);
    final currentQuestion = gameState.currentQuestion;
    final currentUserId = ref.watch(currentUserProvider);

    if (currentQuestion == null) {
      return const Scaffold(
        backgroundColor: SciFiTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: SciFiTheme.primary),
        ),
      );
    }

    final options = List<String>.from(currentQuestion['options'] ?? []);

    return Scaffold(
      body: SciFiBackground(
        child: ReconnectionOverlay(
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
                                      ? SciFiTheme.error
                                      : SciFiTheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SciFiSlider(
                                value: gameState.timeRemaining / 30.0,
                                color:
                                    gameState.timeRemaining < 10
                                        ? SciFiTheme.error
                                        : SciFiTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        'Q ${gameState.questionIndex + 1} / ${gameState.totalQuestions}',
                        style: SciFiTheme.subHeader.copyWith(
                          color: SciFiTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Question Panel
                  SciFiPanel(
                    child: Column(
                      children: [
                        Text(
                          currentQuestion['question'] ?? '',
                          style: SciFiTheme.header.copyWith(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ],
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

                        return SciFiButton(
                          label: option,
                          onPressed:
                              gameState.hasAnswered
                                  ? null
                                  : () {
                                    ref
                                        .read(gameProvider.notifier)
                                        .submitAnswer(option);
                                  },
                          isPrimary: true, // Default style
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
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(
                        child: Text(
                          'Waiting for other players...',
                          style: TextStyle(
                            color: SciFiTheme.textSecondary,
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
                          gameState.isCorrect == true
                              ? 'CORRECT!'
                              : 'INCORRECT',
                          style: SciFiTheme.header.copyWith(
                            color:
                                gameState.isCorrect == true
                                    ? SciFiTheme.success
                                    : SciFiTheme.error,
                          ),
                        ),
                      ),
                    ),

                  // Host Controls
                  if (ref.watch(sessionProvider)?.hostId == currentUserId)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SciFiButton(
                        label: 'END QUIZ',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => SciFiDialog(
                                  title: 'END QUIZ?',
                                  message:
                                      'Are you sure you want to end the quiz early? All progress will be saved.',
                                  confirmText: 'END NOW',
                                  cancelText: 'CANCEL',
                                  isDestructive: true,
                                  onConfirm: () {
                                    Navigator.pop(context); // Close dialog
                                    ref
                                        .read(sessionProvider.notifier)
                                        .endQuiz();
                                  },
                                  onCancel: () => Navigator.pop(context),
                                ),
                          );
                        },
                        isPrimary: false,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
