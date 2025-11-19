import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/websocket_service.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_panel.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';

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
            if (status == ConnectionStatus.connected) return const SizedBox.shrink();

            return Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: SciFiPanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == ConnectionStatus.reconnecting) ...[
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: SciFiTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'RECONNECTING...',
                          style: SciFiTheme.header.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Attempting to restore connection',
                          style: TextStyle(color: SciFiTheme.textSecondary),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.wifi_off,
                          size: 48,
                          color: SciFiTheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'CONNECTION LOST',
                          style: SciFiTheme.header.copyWith(
                            fontSize: 20,
                            color: SciFiTheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check your internet connection',
                          style: TextStyle(color: SciFiTheme.textSecondary),
                        ),
                      ],
                    ],
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
