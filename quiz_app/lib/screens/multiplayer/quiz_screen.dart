import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/game_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/screens/multiplayer/results_screen.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_background.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_button.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_card.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_dialog.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_panel.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_slider.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  Color _getTimerColor(int timeRemaining) {
    if (timeRemaining > 20) return SciFiTheme.success;
    if (timeRemaining > 10) return SciFiTheme.warning;
    return SciFiTheme.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final sessionState = ref.watch(sessionProvider);
    final currentUserId = ref.watch(currentUserProvider);

    ref.listen(sessionProvider, (previous, next) {
      if (next?.status == 'completed') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ResultsScreen()),
        );
      }
    });

    if (gameState.currentQuestion == null) {
      return SciFiBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: SciFiTheme.primary),
              const SizedBox(height: 20),
              Text(
                'LOADING QUESTION...',
                style: SciFiTheme.heading2.copyWith(color: SciFiTheme.primary),
              ),
            ],
          ),
        ),
      );
    }

    final question = gameState.currentQuestion!;
    final options = List<String>.from(question['options'] ?? []);
    final isHost = sessionState?.hostId == currentUserId;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder:
              (context) => SciFiDialog(
                title: 'EXIT QUIZ?',
                message:
                    'Are you sure you want to exit? Your progress will be lost.',
                confirmText: 'EXIT',
                cancelText: 'CONTINUE',
                isDestructive: true,
              ),
        );
        
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: SciFiBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with timer
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sessionState?.quizTitle ?? 'QUIZ',
                        style: SciFiTheme.heading2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getTimerColor(
                          gameState.timeRemaining,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getTimerColor(gameState.timeRemaining),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getTimerColor(
                              gameState.timeRemaining,
                            ).withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        '${gameState.timeRemaining}s',
                        style: SciFiTheme.heading2.copyWith(
                          color: _getTimerColor(gameState.timeRemaining),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Timer Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SciFiSlider(
                  value: gameState.timeRemaining / 30,
                  color: _getTimerColor(gameState.timeRemaining),
                ),
              ),

              const SizedBox(height: 20),

              // Question Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question Number
                      Text(
                        'QUESTION ${gameState.questionIndex + 1}/${gameState.totalQuestions}',
                        style: SciFiTheme.caption.copyWith(
                          color: SciFiTheme.accent,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Question Panel
                      SciFiPanel(
                        glowColor: SciFiTheme.primary,
                        child: Text(
                          question['question_text'] ?? '',
                          style: SciFiTheme.heading2,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Answer Options
                      ...options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final text = entry.value;
                        final isCorrectAnswer =
                            gameState.correctAnswer != null &&
                            (gameState.correctAnswer.toString() ==
                                    index.toString() ||
                                gameState.correctAnswer.toString() == text);

                        bool isPrimary = true;

                        if (gameState.correctAnswer != null) {
                          if (!isCorrectAnswer) {
                            isPrimary = false;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: SciFiButton(
                            label: text,
                            onPressed:
                                gameState.hasAnswered
                                    ? null
                                    : () {
                                      ref
                                          .read(gameProvider.notifier)
                                          .submitAnswer(index);
                                    },
                            isPrimary: isPrimary,
                            height: 70,
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // Waiting Message
                      if (gameState.hasAnswered &&
                          gameState.correctAnswer == null)
                        SciFiPanel(
                          glowColor: SciFiTheme.accent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: SciFiTheme.accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'WAITING FOR OTHER PLAYERS...',
                                style: SciFiTheme.body.copyWith(
                                  color: SciFiTheme.accent,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Answer Result
                      if (gameState.correctAnswer != null) ...[
                        SciFiPanel(
                          glowColor:
                              gameState.isCorrect == true
                                  ? SciFiTheme.success
                                  : SciFiTheme.error,
                          child: Column(
                            children: [
                              Icon(
                                gameState.isCorrect == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color:
                                    gameState.isCorrect == true
                                        ? SciFiTheme.success
                                        : SciFiTheme.error,
                                size: 60,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                gameState.isCorrect == true
                                    ? 'CORRECT!'
                                    : 'INCORRECT',
                                style: SciFiTheme.heading1.copyWith(
                                  color:
                                      gameState.isCorrect == true
                                          ? SciFiTheme.success
                                          : SciFiTheme.error,
                                ),
                              ),
                              if (gameState.pointsEarned != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '+${gameState.pointsEarned} POINTS',
                                  style: SciFiTheme.heading2.copyWith(
                                    color: SciFiTheme.warning,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Leaderboard
                        if (gameState.rankings != null &&
                            gameState.rankings!.isNotEmpty) ...[
                          Text(
                            'LEADERBOARD',
                            style: SciFiTheme.heading2.copyWith(
                              color: SciFiTheme.accent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ...gameState.rankings!.take(5).map((rank) {
                            final isCurrentUser =
                                rank['user_id'] == currentUserId;
                            final position = rank['rank'] as int;
                            Color rankColor = SciFiTheme.primary;

                            if (position == 1) {
                              rankColor = SciFiTheme.warning;
                            } else if (position == 2) {
                              rankColor = const Color(0xFFC0C0C0);
                            } else if (position == 3) {
                              rankColor = const Color(0xFFCD7F32);
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: SciFiCard(
                                glowColor:
                                    isCurrentUser
                                        ? SciFiTheme.accent
                                        : rankColor,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: rankColor.withValues(alpha: 0.3),
                                        border: Border.all(
                                          color: rankColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '#$position',
                                          style: SciFiTheme.body.copyWith(
                                            color: rankColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        rank['user_id'],
                                        style: SciFiTheme.body.copyWith(
                                          fontWeight:
                                              isCurrentUser
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${rank['score']}',
                                      style: SciFiTheme.heading3.copyWith(
                                        color: rankColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],

                      // Host End Quiz Button
                      if (isHost && gameState.correctAnswer == null) ...[
                        const SizedBox(height: 20),
                        SciFiButton(
                          label: 'END QUIZ',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => const SciFiDialog(
                                    title: 'END QUIZ?',
                                    message:
                                        'Are you sure you want to end the quiz early?',
                                    confirmText: 'END',
                                    cancelText: 'CANCEL',
                                    isDestructive: true,
                                  ),
                            );

                            if (confirm == true) {
                              ref.read(sessionProvider.notifier).endQuiz();
                            }
                          },
                          isPrimary: false,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
