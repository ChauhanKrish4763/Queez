import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/widgets/custom_card.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  void _onAssessmentTap(BuildContext context) {
    customNavigate(context, '/assessment_page', AnimationType.fade);
  }

  void _onLearningToolsTap(BuildContext context) {
    customNavigate(context, '/learning_tools_page', AnimationType.fade);
  }

  void _onStudySetTap(BuildContext context) {
    customNavigate(context, '/study_set_mode_selection', AnimationType.fade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomCard(
                title: 'Assessments',
                description: 'Create quizzes, duels, polls, surveys and more!',
                iconPath: 'assets/icons/quiz_icon.png',
                onPressed: () => _onAssessmentTap(context),
                showArrow: true,
              ),
              const SizedBox(height: 28),
              CustomCard(
                title: 'Learning Tools',
                description: 'Flashcards, drag and drop, games and more!',
                iconPath: 'assets/icons/flashcard_icon.png',
                onPressed: () => _onLearningToolsTap(context),
                showArrow: true,
              ),
              const SizedBox(height: 28),
              CustomCard(
                title: 'Study Set',
                description: 'Combine quizzes, flashcards, notes & more!',
                iconPath: 'assets/icons/poll_icon.png',
                onPressed: () => _onStudySetTap(context),
                showArrow: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
