import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/websocket_service.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_panel.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_dialog.dart';

class ReconnectionOverlay extends ConsumerWidget {
  final Widget child;

  const ReconnectionOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);

    return Stack(
      children: [
        child,
        connectionStatus.when(
          data: (status) {
            if (status == ConnectionStatus.reconnecting) {
              return _buildReconnectingOverlay(context);
            } else if (status == ConnectionStatus.disconnected) {
              return _buildDisconnectedOverlay(context);
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildReconnectingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: SciFiPanel(
          glowColor: SciFiTheme.warning,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: SciFiTheme.warning,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'RECONNECTING...',
                style: SciFiTheme.heading2.copyWith(
                  color: SciFiTheme.warning,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we restore your connection',
                style: SciFiTheme.body.copyWith(
                  color: SciFiTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisconnectedOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SciFiPanel(
            glowColor: SciFiTheme.error,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.signal_wifi_off,
                  size: 80,
                  color: SciFiTheme.error,
                ),
                const SizedBox(height: 20),
                Text(
                  'CONNECTION LOST',
                  style: SciFiTheme.heading1.copyWith(
                    color: SciFiTheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Unable to connect to the server.\nPlease check your internet connection.',
                  style: SciFiTheme.body.copyWith(
                    color: SciFiTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Error listener widget
class ErrorListener extends ConsumerStatefulWidget {
  final Widget child;

  const ErrorListener({super.key, required this.child});

  @override
  ConsumerState<ErrorListener> createState() => _ErrorListenerState();
}

class _ErrorListenerState extends ConsumerState<ErrorListener> {
  @override
  void initState() {
    super.initState();
    
    // Listen to error stream
    Future.microtask(() {
      final notifier = ref.read(sessionProvider.notifier);
      notifier.errorStream.listen((error) {
        if (mounted) {
          _showErrorDialog(error);
        }
      });
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => SciFiDialog(
        title: 'ERROR',
        message: message,
        confirmText: 'OK',
        isDestructive: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
