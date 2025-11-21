import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/websocket_service.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

class ReconnectionOverlay extends ConsumerWidget {
  final Widget child;

  const ReconnectionOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatusAsync = ref.watch(connectionStatusProvider);

    return Stack(
      children: [
        child,
        connectionStatusAsync.when(
          data: (status) {
            if (status == ConnectionStatus.connected) {
              return const SizedBox.shrink();
            }

            return Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(QuizSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(QuizSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status == ConnectionStatus.reconnecting) ...[
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: QuizSpacing.md),
                          const Text(
                            'RECONNECTING...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: QuizSpacing.sm),
                          Text(
                            'Attempting to restore connection',
                            style: TextStyle(color: QuizColors.textSecondary),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.wifi_off,
                            size: 48,
                            color: QuizColors.incorrect,
                          ),
                          const SizedBox(height: QuizSpacing.md),
                          const Text(
                            'CONNECTION LOST',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: QuizColors.incorrect,
                            ),
                          ),
                          const SizedBox(height: QuizSpacing.sm),
                          Text(
                            'Please check your internet connection',
                            style: TextStyle(color: QuizColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
