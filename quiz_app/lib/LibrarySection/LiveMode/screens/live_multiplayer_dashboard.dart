import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_lobby.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/utils/color.dart';

class LiveMultiplayerDashboard extends ConsumerStatefulWidget {
  final String quizId;
  final String sessionCode;

  const LiveMultiplayerDashboard({
    super.key,
    required this.quizId,
    required this.sessionCode,
  });

  @override
  ConsumerState<LiveMultiplayerDashboard> createState() =>
      _LiveMultiplayerDashboardState();
}

class _LiveMultiplayerDashboardState
    extends ConsumerState<LiveMultiplayerDashboard> {
  bool _isJoining = false;

  Future<void> _joinSession() async {
    setState(() => _isJoining = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId =
          user?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

      // ✅ FIXED: Properly extract username with fallbacks
      final username =
          user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!
              : (user?.email?.split('@')[0] ??
                  'Player_${userId.substring(userId.length - 4)}');

      // Wait for join to complete and session state to be received
      await ref
          .read(sessionProvider.notifier)
          .joinSession(widget.sessionCode, userId, username);

      // Only navigate after successful join
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => LiveMultiplayerLobby(
                  sessionCode: widget.sessionCode,
                  isHost: false,
                ),
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Connection timeout. Please check your internet and try again.',
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to join session';
        if (e.toString().contains('Session not found')) {
          errorMessage = 'Invalid session code. Please check and try again.';
        } else if (e.toString().contains('already active')) {
          errorMessage = 'This session has already started.';
        } else {
          errorMessage =
              'Failed to join: ${e.toString().replaceAll('Exception: ', '')}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Live Multiplayer',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
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
                      const Icon(
                        Icons.groups_rounded,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Live Multiplayer Session',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Session Code',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.sessionCode,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'This is a temporary live multiplayer session.\nThe quiz will not be saved to your library.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _isJoining ? null : _joinSession,
                        icon:
                            _isJoining
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                                : const Icon(Icons.login, size: 20),
                        label: Text(
                          _isJoining ? 'Joining...' : 'Join Session',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
