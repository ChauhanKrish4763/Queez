import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

/// Represents the visual state of a quiz option
enum QuizOptionState {
  /// Default unselected state
  neutral,
  /// User has selected this option (before answer revealed)
  selected,
  /// This option is the correct answer
  correct,
  /// User selected this option but it was wrong
  incorrect,
}

/// A reusable option card widget for quiz questions.
/// Used by both single player and multiplayer modes.
class QuizOptionCard extends StatelessWidget {
  final String text;
  final QuizOptionState state;
  final VoidCallback? onTap;
  final String? optionLabel; // e.g., "A", "B", "C" or null for no label
  final bool showIcon;
  final bool enabled;

  const QuizOptionCard({
    super.key,
    required this.text,
    this.state = QuizOptionState.neutral,
    this.onTap,
    this.optionLabel,
    this.showIcon = true,
    this.enabled = true,
  });

  Color _getBorderColor() {
    switch (state) {
      case QuizOptionState.selected:
        return AppColors.primary;
      case QuizOptionState.correct:
        return AppColors.success;
      case QuizOptionState.incorrect:
        return AppColors.error;
      case QuizOptionState.neutral:
        return AppColors.surface;
    }
  }

  Color _getBackgroundColor() {
    switch (state) {
      case QuizOptionState.selected:
        return AppColors.primaryLighter;
      case QuizOptionState.correct:
        return AppColors.success.withValues(alpha: 0.1);
      case QuizOptionState.incorrect:
        return AppColors.error.withValues(alpha: 0.1);
      case QuizOptionState.neutral:
        return AppColors.surface;
    }
  }

  IconData? _getIcon() {
    if (!showIcon) return null;
    switch (state) {
      case QuizOptionState.correct:
        return Icons.check_circle;
      case QuizOptionState.incorrect:
        return Icons.cancel;
      default:
        return null;
    }
  }

  Color _getIconColor() {
    switch (state) {
      case QuizOptionState.correct:
        return AppColors.success;
      case QuizOptionState.incorrect:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Option label (A, B, C, etc.)
                if (optionLabel != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: state == QuizOptionState.neutral
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : _getBorderColor().withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        optionLabel!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: state == QuizOptionState.neutral
                              ? AppColors.primary
                              : _getBorderColor(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                // Option text
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Feedback icon
                if (icon != null) ...[
                  const SizedBox(width: 12),
                  Icon(icon, color: _getIconColor(), size: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
