import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/widgets/custom_card.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  void _onAssessmentTap(BuildContext context) {
    customNavigate(
      context,
      '/assessment_page',
      AnimationType.fade,
    );
  }

  void _onLearningToolsTap(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Learning Tools tapped!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomCard(
                title: 'Assessments',
                description: 'Create quizzes, duels, polls, surveys and more!',
                iconPath: 'assets/icons/quiz_icon.png',
                onPressed: () => _onAssessmentTap(context),
              ),
              const SizedBox(height: 28),
              CustomCard(
                title: 'Learning Tools',
                description: 'Flashcards, drag and drop, games and more!',
                iconPath: 'assets/icons/flashcard_icon.png',
                onPressed: () => _onLearningToolsTap(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
