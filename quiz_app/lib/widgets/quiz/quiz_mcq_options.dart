import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/quiz/quiz_option_card.dart';

/// A reusable MCQ options widget for quiz questions.
/// Supports both single-select and multi-select modes.
/// Used by both single player and multiplayer modes.
class QuizMcqOptions extends StatefulWidget {
  final List<String> options;
  final dynamic userAnswer; // int for single, List<int> for multi
  final ValueChanged<dynamic> onAnswerSelected;
  final bool isMultiSelect;
  final int? correctAnswerIndex; // For single select
  final List<int>? correctAnswerIndices; // For multi select
  final bool hasAnswered;
  final bool enabled;

  const QuizMcqOptions({
    super.key,
    required this.options,
    required this.userAnswer,
    required this.onAnswerSelected,
    this.isMultiSelect = false,
    this.correctAnswerIndex,
    this.correctAnswerIndices,
    this.hasAnswered = false,
    this.enabled = true,
  });

  @override
  State<QuizMcqOptions> createState() => _QuizMcqOptionsState();
}

class _QuizMcqOptionsState extends State<QuizMcqOptions> {
  late List<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  @override
  void didUpdateWidget(QuizMcqOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset selection when question changes (options change)
    if (widget.options.length != oldWidget.options.length ||
        (widget.options.isNotEmpty && oldWidget.options.isNotEmpty &&
            widget.options[0] != oldWidget.options[0])) {
      _initializeSelection();
    }
    // Also reset if hasAnswered goes from true to false (new question)
    if (!widget.hasAnswered && oldWidget.hasAnswered) {
      _initializeSelection();
    }
  }

  void _initializeSelection() {
    if (widget.isMultiSelect) {
      if (widget.userAnswer is List) {
        _selectedIndices = List<int>.from(widget.userAnswer);
      } else {
        _selectedIndices = [];
      }
    } else {
      _selectedIndices = widget.userAnswer != null ? [widget.userAnswer as int] : [];
    }
  }

  void _handleTap(int index) {
    if (!widget.enabled || widget.hasAnswered) return;
    if (widget.userAnswer != null && !widget.isMultiSelect) return; // Already answered single

    if (widget.isMultiSelect) {
      setState(() {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
      });
    } else {
      widget.onAnswerSelected(index);
    }
  }

  QuizOptionState _getOptionState(int index) {
    // Determine if this option is selected
    final bool isSelected = widget.isMultiSelect
        ? _selectedIndices.contains(index)
        : widget.userAnswer == index;

    // Determine if this option is the correct answer
    final bool isCorrectOption = widget.isMultiSelect
        ? (widget.correctAnswerIndices?.contains(index) ?? false)
        : widget.correctAnswerIndex == index;

    // For single select: show feedback immediately when user has answered
    // For multi select: show feedback when correctAnswerIndices is provided
    final bool hasUserAnswered = widget.isMultiSelect
        ? (widget.userAnswer != null && widget.userAnswer is List && (widget.userAnswer as List).isNotEmpty)
        : widget.userAnswer != null;

    final bool hasCorrectAnswer = widget.isMultiSelect
        ? widget.correctAnswerIndices != null
        : widget.correctAnswerIndex != null;

    // Show instant feedback when user has answered AND we know the correct answer
    if (hasUserAnswered && hasCorrectAnswer) {
      if (isCorrectOption) return QuizOptionState.correct;
      if (isSelected && !isCorrectOption) return QuizOptionState.incorrect;
      return QuizOptionState.neutral;
    }

    // Before answering or without correct answer info, just show selection state
    if (isSelected) return QuizOptionState.selected;
    return QuizOptionState.neutral;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          widget.options.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.options.length - 1 ? 12 : 0,
            ),
            child: QuizOptionCard(
              text: widget.options[index],
              state: _getOptionState(index),
              optionLabel: String.fromCharCode(65 + index), // A, B, C, D...
              onTap: () => _handleTap(index),
              enabled: widget.enabled && !widget.hasAnswered,
            ),
          ),
        ),
        // Submit button for multi-select
        if (widget.isMultiSelect && !widget.hasAnswered && widget.userAnswer == null) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedIndices.isNotEmpty
                  ? () => widget.onAnswerSelected(_selectedIndices.toList()..sort())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.disabledBackground,
                disabledForegroundColor: AppColors.textDisabled,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selectedIndices.isEmpty
                    ? 'Select at least one option'
                    : 'Submit (${_selectedIndices.length} selected)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
