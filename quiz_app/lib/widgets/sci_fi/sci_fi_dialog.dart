import 'package:flutter/material.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_button.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_panel.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';

class SciFiDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback? onConfirm;
  final String? cancelText;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const SciFiDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.onConfirm,
    this.cancelText,
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: SciFiPanel(
        width: double.infinity,
        glowColor: isDestructive ? SciFiTheme.error : SciFiTheme.primary,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              style: SciFiTheme.heading2.copyWith(
                color: isDestructive ? SciFiTheme.error : SciFiTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: SciFiTheme.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cancelText != null) ...[
                  Expanded(
                    child: SciFiButton(
                      label: cancelText!,
                      onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: SciFiButton(
                    label: confirmText,
                    onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                    isPrimary: !isDestructive,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
