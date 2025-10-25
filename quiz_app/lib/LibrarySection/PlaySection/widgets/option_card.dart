import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

enum OptionState { neutral, selected, correct, incorrect }

class OptionCard extends StatelessWidget {
  final String text;
  final OptionState state;
  final VoidCallback onTap;

  const OptionCard({
    Key? key,
    required this.text,
    this.state = OptionState.neutral,
    required this.onTap,
  }) : super(key: key);

  Color _getBorderColor() {
    switch (state) {
      case OptionState.selected:
        return AppColors.primary;
      case OptionState.correct:
        return AppColors.success;
      case OptionState.incorrect:
        return AppColors.error;
      case OptionState.neutral:
      default:
        return AppColors.surface;
    }
  }

  Color _getBackgroundColor() {
    switch (state) {
      case OptionState.selected:
        return AppColors.primaryLighter;
      case OptionState.correct:
        return AppColors.success.withOpacity(0.1);
      case OptionState.incorrect:
        return AppColors.error.withOpacity(0.1);
      case OptionState.neutral:
      default:
        return AppColors.surface;
    }
  }

  IconData? _getIcon() {
    switch (state) {
      case OptionState.correct:
        return Icons.check_circle;
      case OptionState.incorrect:
        return Icons.cancel;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_getIcon() != null) ...[
                const SizedBox(width: 12),
                Icon(_getIcon(), color: _getBorderColor()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
