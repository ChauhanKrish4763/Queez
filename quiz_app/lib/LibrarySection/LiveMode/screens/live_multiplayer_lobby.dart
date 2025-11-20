import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_quiz.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/reconnection_overlay.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_background.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_button.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_card.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_dialog.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_panel.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_transition.dart';

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
        Navigator.pushReplacement(
          context,
          SciFiPageTransition(child: const LiveMultiplayerQuiz()),
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

      return const Scaffold(
        backgroundColor: SciFiTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: SciFiTheme.primary),
              SizedBox(height: 16),
              Text(
                'LOADING SESSION...',
                style: TextStyle(
                  color: SciFiTheme.textSecondary,
                  fontFamily: 'Orbitron',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SciFiBackground(
        child: ReconnectionOverlay(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  SciFiPanel(
                    child: Column(
                      children: [
                        Text(
                          'SESSION CODE',
                          style: SciFiTheme.subHeader.copyWith(
                            color: SciFiTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.sessionCode,
                          style: SciFiTheme.header.copyWith(
                            fontSize: 48,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Participants Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PARTICIPANTS', style: SciFiTheme.subHeader),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SciFiTheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SciFiTheme.primary),
                        ),
                        child: Text(
                          '${sessionState.participantCount}',
                          style: SciFiTheme.body.copyWith(
                            color: SciFiTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Participants List
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3,
                          ),
                      itemCount: sessionState.participants.length,
                      itemBuilder: (context, index) {
                        final participant = sessionState.participants[index];
                        return SciFiCard(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                color: SciFiTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  participant.username,
                                  style: SciFiTheme.body.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Status / Actions
                  if (widget.isHost)
                    SciFiButton(
                      label: 'START QUIZ',
                      onPressed:
                          sessionState.participantCount >= 1
                              ? () {
                                ref.read(sessionProvider.notifier).startQuiz();
                              }
                              : null,
                      isPrimary: true,
                    )
                  else
                    const SciFiPanel(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                SciFiTheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'WAITING FOR HOST...',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              color: SciFiTheme.textSecondary,
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
        ),
      ),
    );
  }
}
