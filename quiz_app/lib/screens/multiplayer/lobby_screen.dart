import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/screens/multiplayer/quiz_screen.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_background.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_panel.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_button.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_card.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_dialog.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final String sessionCode;
  final String userId;
  final String username;

  const LobbyScreen({
    super.key,
    required this.sessionCode,
    required this.userId,
    required this.username,
  });

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    
    // Listen for status changes to navigate
    ref.listen(sessionProvider, (previous, next) {
      if (next?.status == 'active') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const QuizScreen()),
        );
      }
    });

    // Listen for errors
    ref.listen(sessionProvider.select((state) => state), (previous, next) {
      // Error handling will be done via error stream
    });

    if (sessionState == null) {
      return SciFiBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: SciFiTheme.primary),
              const SizedBox(height: 20),
              Text(
                'CONNECTING...',
                style: SciFiTheme.heading2.copyWith(color: SciFiTheme.primary),
              ),
            ],
          ),
        ),
      );
    }

    final isHost = sessionState.hostId == widget.userId;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => SciFiDialog(
            title: 'LEAVE SESSION?',
            message: 'Are you sure you want to leave this session?',
            confirmText: 'LEAVE',
            cancelText: 'STAY',
            isDestructive: true,
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: SciFiBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'WAITING LOBBY',
                  style: SciFiTheme.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Session Code Panel
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: SciFiPanel(
                    glowColor: SciFiTheme.primary,
                    child: Column(
                      children: [
                        Text(
                          'SESSION CODE',
                          style: SciFiTheme.caption.copyWith(
                            color: SciFiTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.sessionCode,
                          style: SciFiTheme.heading1.copyWith(
                            fontSize: 48,
                            letterSpacing: 8,
                            color: SciFiTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Participants Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PARTICIPANTS',
                      style: SciFiTheme.heading2,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: SciFiTheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SciFiTheme.primary, width: 2),
                      ),
                      child: Text(
                        '${sessionState.participantCount}',
                        style: SciFiTheme.heading2.copyWith(color: SciFiTheme.primary),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Participants List
                Expanded(
                  child: ListView.builder(
                    itemCount: sessionState.participants.length,
                    itemBuilder: (context, index) {
                      final participant = sessionState.participants[index];
                      final isThisHost = participant.userId == sessionState.hostId;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SciFiCard(
                          glowColor: participant.connected 
                              ? (isThisHost ? SciFiTheme.warning : SciFiTheme.success)
                              : Colors.grey,
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: participant.connected
                                      ? SciFiTheme.primary.withValues(alpha: 0.3)
                                      : Colors.grey.withValues(alpha: 0.3),
                                  border: Border.all(
                                    color: participant.connected
                                        ? SciFiTheme.primary
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    participant.username[0].toUpperCase(),
                                    style: SciFiTheme.heading2.copyWith(
                                      color: participant.connected
                                          ? SciFiTheme.primary
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Username
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          participant.username,
                                          style: SciFiTheme.body.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (isThisHost) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.stars,
                                            color: SciFiTheme.warning,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'HOST',
                                            style: SciFiTheme.caption.copyWith(
                                              color: SciFiTheme.warning,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      participant.connected ? 'CONNECTED' : 'DISCONNECTED',
                                      style: SciFiTheme.caption.copyWith(
                                        color: participant.connected
                                            ? SciFiTheme.success
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Status Icon
                              Icon(
                                participant.connected
                                    ? Icons.check_circle
                                    : Icons.offline_bolt,
                                color: participant.connected
                                    ? SciFiTheme.success
                                    : Colors.grey,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action Button
                if (isHost)
                  SciFiButton(
                    label: 'START QUIZ',
                    onPressed: () {
                      if (sessionState.participantCount < 2) {
                        showDialog(
                          context: context,
                          builder: (context) => const SciFiDialog(
                            title: 'INSUFFICIENT PLAYERS',
                            message: 'At least 2 participants are required to start the quiz.',
                            confirmText: 'OK',
                          ),
                        );
                      } else {
                        ref.read(sessionProvider.notifier).startQuiz();
                      }
                    },
                    isPrimary: true,
                  )
                else
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
                          'WAITING FOR HOST TO START...',
                          style: SciFiTheme.body.copyWith(
                            color: SciFiTheme.accent,
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
