import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_host_view.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_quiz.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

class LiveMultiplayerLobby extends ConsumerStatefulWidget {
  final String sessionCode;
  final bool isHost;

  const LiveMultiplayerLobby({
    super.key,
    required this.sessionCode,
    this.isHost = false,
  });

  @override
  ConsumerState<LiveMultiplayerLobby> createState() =>
      _LiveMultiplayerLobbyState();
}

class _LiveMultiplayerLobbyState extends ConsumerState<LiveMultiplayerLobby> {
  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (next != null && next.status == 'active') {
        // Route based on role
        if (widget.isHost) {
          // Host sees leaderboard only
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => LiveHostView(sessionCode: widget.sessionCode),
            ),
          );
        } else {
          // Participants see quiz
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LiveMultiplayerQuiz(),
            ),
          );
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

    final sessionState = ref.watch(sessionProvider);

    if (sessionState == null) {
      // This should rarely happen now, but add safety timeout
      Future.delayed(const Duration(seconds: 5), () {
        if (context.mounted && ref.read(sessionProvider) == null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load session. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: QuizSpacing.md),
              Text(
                'LOADING SESSION...',
                style: TextStyle(
                  color: QuizColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        Text(
                          'SESSION CODE',
                          style: TextStyle(
                            color: QuizColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: QuizSpacing.sm),
                        Text(
                          widget.sessionCode,
                          style: TextStyle(
                            fontSize: 48,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: QuizSpacing.xl),

                // Participants Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PARTICIPANTS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: QuizSpacing.md,
                        vertical: QuizSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        '${sessionState.participantCount}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: QuizSpacing.md),

                // Participants List
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: QuizSpacing.md,
                          mainAxisSpacing: QuizSpacing.md,
                          childAspectRatio: 3,
                        ),
                    itemCount: sessionState.participants.length,
                    itemBuilder: (context, index) {
                      final participant = sessionState.participants[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(QuizSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: QuizColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: QuizSpacing.sm),
                              Expanded(
                                child: Text(
                                  participant.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: QuizSpacing.lg),

                // Status / Actions
                if (widget.isHost)
                  ElevatedButton(
                    onPressed:
                        sessionState.participantCount >= 1
                            ? () {
                              ref.read(sessionProvider.notifier).startQuiz();
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: QuizSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                      ),
                    ),
                    child: const Text(
                      'START QUIZ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(QuizSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: QuizSpacing.md),
                          Text(
                            'WAITING FOR HOST...',
                            style: TextStyle(
                              color: QuizColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
