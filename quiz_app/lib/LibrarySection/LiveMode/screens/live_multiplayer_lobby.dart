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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LiveHostView(sessionCode: widget.sessionCode),
            ),
          );
        } else {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    });

    final sessionState = ref.watch(sessionProvider);

    if (sessionState == null) {
      Future.delayed(const Duration(seconds: 8), () {
        if (context.mounted && ref.read(sessionProvider) == null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection timeout. Check your internet and try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      });

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: QuizSpacing.xl),
              Text(
                'Connecting to session...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: QuizSpacing.sm),
              Text(
                'Session Code: ${widget.sessionCode}',
                style: TextStyle(
                  color: QuizColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isHost ? 'Host Lobby' : 'Waiting Room',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ReconnectionOverlay(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(QuizSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Session Code Card
                Container(
                  padding: const EdgeInsets.all(QuizSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SESSION CODE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: QuizSpacing.sm),
                      Text(
                        widget.sessionCode,
                        style: const TextStyle(
                          fontSize: 42,
                          letterSpacing: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: QuizSpacing.xl),

                // Participants Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: QuizSpacing.md,
                    vertical: QuizSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: QuizSpacing.sm),
                          const Text(
                            'Players',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: QuizSpacing.md,
                          vertical: QuizSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
                        ),
                        child: Text(
                          '${sessionState.participantCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: QuizSpacing.md),

                // Participants List
                Expanded(
                  child: sessionState.participants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 64,
                                color: QuizColors.textSecondary,
                              ),
                              const SizedBox(height: QuizSpacing.md),
                              Text(
                                'Waiting for players to join...',
                                style: TextStyle(
                                  color: QuizColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: sessionState.participants.length,
                          itemBuilder: (context, index) {
                            final participant = sessionState.participants[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: QuizSpacing.sm),
                              padding: const EdgeInsets.all(QuizSpacing.md),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    radius: 20,
                                    child: Text(
                                      participant.username[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: QuizSpacing.md),
                                  Expanded(
                                    child: Text(
                                      participant.username,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: QuizSpacing.lg),

                // Action Button
                if (widget.isHost)
                  ElevatedButton(
                    onPressed: sessionState.participantCount >= 1
                        ? () {
                            ref.read(sessionProvider.notifier).startQuiz();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: QuizSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                      ),
                      disabledBackgroundColor: Colors.grey.shade800,
                    ),
                    child: Text(
                      sessionState.participantCount >= 1
                          ? 'START QUIZ'
                          : 'WAITING FOR PLAYERS',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(QuizSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
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
                        const Text(
                          'Waiting for host to start...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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
    );
  }
}
