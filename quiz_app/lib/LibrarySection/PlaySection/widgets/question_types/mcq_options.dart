import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/LibrarySection/PlaySection/widgets/option_card.dart';
import 'package:quiz_app/utils/color.dart';

class McqOptions extends StatefulWidget {
  final Question question;
  final dynamic userAnswer;
  final ValueChanged<dynamic> onAnswerSelected;
  final bool isMultiSelect;

  const McqOptions({
    Key? key,
    required this.question,
    required this.userAnswer,
    required this.onAnswerSelected,
    this.isMultiSelect = false,
  }) : super(key: key);

  @override
  State<McqOptions> createState() => _McqOptionsState();
}

class _McqOptionsState extends State<McqOptions> {
  late List<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    if (widget.isMultiSelect) {
      _selectedIndices = [];
    } else {
      _selectedIndices = widget.userAnswer != null ? [widget.userAnswer] : [];
    }
  }

  void _handleTap(int index) {
    if (widget.userAnswer != null) return; // Already answered

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

  OptionState _getOptionState(int index) {
    final bool isSelected =
        widget.isMultiSelect
            ? _selectedIndices.contains(index)
            : widget.userAnswer == index;

    if (widget.userAnswer != null) {
      // Answer has been submitted
      final bool isCorrect =
          widget.isMultiSelect
              ? widget.question.correctAnswerIndices!.contains(index)
              : widget.question.correctAnswerIndex == index;

      if (isCorrect) return OptionState.correct;
      if (isSelected && !isCorrect) return OptionState.incorrect;
    }

    if (isSelected) return OptionState.selected;
    return OptionState.neutral;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          widget.question.options.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.question.options.length - 1 ? 12 : 0,
            ),
            child: OptionCard(
              text: widget.question.options[index],
              state: _getOptionState(index),
              onTap: () => _handleTap(index),
            ),
          ),
        ),
        if (widget.isMultiSelect && widget.userAnswer == null) ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                _selectedIndices.isNotEmpty
                    ? () => widget.onAnswerSelected(_selectedIndices)
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }
}
