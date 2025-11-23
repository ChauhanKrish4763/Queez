import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/screens/flashcard_details_page.dart';
import 'package:quiz_app/CreateSection/widgets/custom_card.dart';
import 'package:quiz_app/utils/color.dart';

class LearningToolsPage extends StatelessWidget {
  const LearningToolsPage({super.key});

  void _onFlashcardsTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FlashcardDetailsPage()),
    );
  }

  void _onNotesTap(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Create Notes tapped!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Learning Tools',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.iconActive),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomCard(
                title: 'Flashcards',
                description:
                    'Create digital flashcards for effective study and revision',
                iconPath: 'assets/icons/flashcard_icon.png',
                onPressed: () => _onFlashcardsTap(context),
                showArrow: true,
              ),
              const SizedBox(height: 28),
              CustomCard(
                title: 'Notes',
                description:
                    'Capture ideas, summarize topics, and organize your thoughts',
                iconPath: 'assets/icons/survey_icon.png',
                onPressed: () => _onNotesTap(context),
                showArrow: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
