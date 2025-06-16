import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/widgets/custom_text_field.dart';
import '../models/question.dart';
import '../widgets/custom_dropdown.dart';
import 'package:quiz_app/utils/color.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(Question) onQuestionUpdated;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.onQuestionUpdated,
  }) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with TickerProviderStateMixin {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  late ValueNotifier<int?> _correctAnswerNotifier;

  @override
  void initState() {
    super.initState();
    _correctAnswerNotifier = ValueNotifier<int?>(widget.question.correctAnswerIndex);
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  void _initializeControllers() {
    _questionController = TextEditingController(text: widget.question.questionText);
    _optionControllers = widget.question.options
        .map((option) => TextEditingController(text: option))
        .toList();
    
    _questionController.addListener(_updateQuestion);
    for (var controller in _optionControllers) {
      controller.addListener(_updateQuestion);
    }
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _disposeControllers();
      _correctAnswerNotifier.value = widget.question.correctAnswerIndex;
      _initializeControllers();
      _slideController.reset();
      _fadeController.reset();
      _scaleController.reset();
      _slideController.forward();
      _fadeController.forward();
      _scaleController.forward();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    _correctAnswerNotifier.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    _questionController.removeListener(_updateQuestion);
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.removeListener(_updateQuestion);
      controller.dispose();
    }
  }

  void _updateQuestion() {
    widget.question.questionText = _questionController.text;
    widget.question.options = _optionControllers.map((c) => c.text).toList();
    widget.onQuestionUpdated(widget.question);
  }

  void _selectCorrectAnswer(int index) {
    widget.question.correctAnswerIndex = index;
    _correctAnswerNotifier.value = index;
    widget.onQuestionUpdated(widget.question);
  }

  void _changeQuestionType(String? typeString) {
    if (typeString == null) return;
    
    QuestionType newType = Question.typeFromString(typeString);
    setState(() {
      widget.question.type = newType;
      widget.question.correctAnswerIndex = null;
      _correctAnswerNotifier.value = null;
      
      for (var controller in _optionControllers) {
        controller.removeListener(_updateQuestion);
        controller.dispose();
      }
      
      if (newType == QuestionType.trueFalse) {
        widget.question.options = ['True', 'False'];
      } else {
        widget.question.options = ['', '', '', ''];
      }
      
      _optionControllers = widget.question.options
          .map((option) => TextEditingController(text: option))
          .toList();
      
      for (var controller in _optionControllers) {
        controller.addListener(_updateQuestion);
      }
    });
    widget.onQuestionUpdated(widget.question);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomDropdown(
                          value: widget.question.typeString,
                          items: const ['Multiple Choice', 'True/False'],
                          hintText: 'Select question type',
                          onChanged: _changeQuestionType,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Your Question',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _questionController,
                          hintText: 'Enter your question here...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Answer Options',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click the circle to mark the correct answer',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(widget.question.options.length, (index) {
                          return OptionItem(
                            key: ValueKey('option_${widget.question.id}_$index'),
                            index: index,
                            question: widget.question,
                            controller: _optionControllers[index],
                            correctAnswerNotifier: _correctAnswerNotifier,
                            onCorrectAnswerSelected: _selectCorrectAnswer,
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OptionItem extends StatefulWidget {
  final int index;
  final Question question;
  final TextEditingController controller;
  final ValueNotifier<int?> correctAnswerNotifier;
  final Function(int) onCorrectAnswerSelected;

  const OptionItem({
    Key? key,
    required this.index,
    required this.question,
    required this.controller,
    required this.correctAnswerNotifier,
    required this.onCorrectAnswerSelected,
  }) : super(key: key);

  @override
  State<OptionItem> createState() => _OptionItemState();
}

class _OptionItemState extends State<OptionItem> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: widget.correctAnswerNotifier,
      builder: (context, correctAnswerIndex, child) {
        bool isCorrect = correctAnswerIndex == widget.index;
        bool isReadOnly = widget.question.type == QuestionType.trueFalse;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isCorrect 
                ? AppColors.success.withOpacity(0.08)
                : AppColors.background,
            border: Border.all(
              color: isCorrect 
                  ? AppColors.success
                  : AppColors.primaryLight.withOpacity(0.3),
              width: isCorrect ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isCorrect ? [
              BoxShadow(
                color: AppColors.success.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => widget.onCorrectAnswerSelected(widget.index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect 
                          ? AppColors.success
                          : Colors.transparent,
                      border: Border.all(
                        color: isCorrect 
                            ? AppColors.success
                            : AppColors.iconInactive,
                        width: 2,
                      ),
                    ),
                    child: isCorrect
                        ? const Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: isReadOnly 
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLighter.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: double.infinity,
                          child: Text(
                            widget.question.options[widget.index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                      : CustomTextField(
                          controller: widget.controller,
                          hintText: 'Option ${String.fromCharCode(65 + widget.index)}',
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}