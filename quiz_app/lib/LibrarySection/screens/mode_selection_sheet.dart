import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_lobby.dart';
import 'package:quiz_app/LibrarySection/services/session_service.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

/// Example widget showing how to select a mode and navigate to LiveMultiplayerLobby
/// You can integrate this into your existing quiz creation/selection flow
class ModeSelectionSheet extends ConsumerStatefulWidget {
  final String quizId;
  final String quizTitle;
  final String hostId;

  const ModeSelectionSheet({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.hostId,
  });

  @override
  ConsumerState<ModeSelectionSheet> createState() => _ModeSelectionSheetState();
}

class _ModeSelectionSheetState extends ConsumerState<ModeSelectionSheet> {
  bool _isCreatingSession = false;

  Future<void> _createSessionAndNavigate(String mode) async {
    if (mode != 'live_multiplayer') {
      // For other modes, show a message (not implemented yet)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$mode mode coming soon!'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    setState(() => _isCreatingSession = true);

    try {
      // Create session
      final result = await SessionService.createSession(
        quizId: widget.quizId,
        hostId: widget.hostId,
        mode: mode,
      );

      if (result['success'] == true && mounted) {
        final sessionCode = result['session_code'] as String;

        // Connect host to WebSocket
        final user = FirebaseAuth.instance.currentUser;
        final username =
            user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName!
                : (user?.email?.split('@')[0] ?? 'Host');

        await ref
            .read(sessionProvider.notifier)
            .joinSession(sessionCode, widget.hostId, username);

        // Close bottom sheet and navigate to lobby
        if (mounted) {
          Navigator.pop(context); // Close bottom sheet
          Navigator.push(
            context,
            customRoute(
              LiveMultiplayerLobby(
                sessionCode: sessionCode,
                isHost: true,
              ),
              AnimationType.slideUp,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create session: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingSession = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Select Quiz Mode',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how participants will take this quiz',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Share Mode
              _buildModeCard(
                context: context,
                icon: Icons.share,
                title: 'Share',
                description:
                    'Share this quiz with others and add it to their library for later access',
                color: AppColors.primary,
                mode: 'share',
              ),
              const SizedBox(height: 16),

              // Live Multiplayer Mode
              _buildModeCard(
                context: context,
                icon: Icons.group,
                title: 'Live Multiplayer',
                description:
                    'Host a live quiz session where all participants answer together in real-time',
                color: AppColors.secondary,
                mode: 'live_multiplayer',
              ),
              const SizedBox(height: 16),

              // Self-Paced Mode
              _buildModeCard(
                context: context,
                icon: Icons.person,
                title: 'Self-Paced',
                description:
                    'Play the quiz at your own pace without time pressure',
                color: AppColors.accentBright,
                mode: 'self_paced',
              ),
              const SizedBox(height: 16),

              // Timed Individual Mode
              _buildModeCard(
                context: context,
                icon: Icons.timer,
                title: 'Timed Individual',
                description:
                    'Challenge yourself to complete the quiz within a time limit',
                color: Colors.orange,
                mode: 'timed_individual',
              ),
              const SizedBox(height: 16),

              // Loading indicator
              if (_isCreatingSession) ...[
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Creating session...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Cancel button
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isCreatingSession ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String mode,
  }) {
    return InkWell(
      onTap: _isCreatingSession ? null : () => _createSessionAndNavigate(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Example function to show the mode selection sheet
/// Call this from your quiz detail page or library
void showModeSelection({
  required BuildContext context,
  required String quizId,
  required String quizTitle,
  required String hostId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => ModeSelectionSheet(
          quizId: quizId,
          quizTitle: quizTitle,
          hostId: hostId,
        ),
  );
}
