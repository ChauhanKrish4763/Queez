import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/LibrarySection/screens/hosting_page.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

/// Example widget showing how to select a mode and navigate to HostingPage
/// You can integrate this into your existing quiz creation/selection flow
class ModeSelectionSheet extends StatelessWidget {
  final String quizId;
  final String quizTitle;
  final String hostId;

  const ModeSelectionSheet({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.hostId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(QuizSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(QuizBorderRadius.xl)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
                  ),
                ),
              ),
              const SizedBox(height: QuizSpacing.lg),

              Text(
                'Select Quiz Mode',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: QuizSpacing.sm),
              Text(
                'Choose how participants will take this quiz',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: QuizSpacing.lg),

              // Share Mode
              _buildModeCard(
                context: context,
                icon: Icons.share,
                title: 'Share',
                description:
                    'Share this quiz with others and add it to their library for later access',
                color: AppColors.primary,
                mode: 'share',
              ),
              const SizedBox(height: QuizSpacing.md),

              // Live Multiplayer Mode
              _buildModeCard(
                context: context,
                icon: Icons.group,
                title: 'Live Multiplayer',
                description:
                    'Host a live quiz session where all participants answer together in real-time',
                color: AppColors.secondary,
                mode: 'live_multiplayer',
              ),
              const SizedBox(height: QuizSpacing.md),

              // Self-Paced Mode
              _buildModeCard(
                context: context,
                icon: Icons.person,
                title: 'Self-Paced',
                description:
                    'Play the quiz at your own pace without time pressure',
                color: AppColors.accentBright,
                mode: 'self_paced',
              ),
              const SizedBox(height: QuizSpacing.md),

              // Timed Individual Mode
              _buildModeCard(
                context: context,
                icon: Icons.timer,
                title: 'Timed Individual',
                description:
                    'Challenge yourself to complete the quiz within a time limit',
                color: AppColors.warning,
                mode: 'timed_individual',
              ),
              const SizedBox(height: QuizSpacing.md),

              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: QuizSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String mode,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close bottom sheet

        // Navigate to HostingPage with slide up animation
        Navigator.push(
          context,
          customRoute(
            HostingPage(
              quizId: quizId,
              quizTitle: quizTitle,
              mode: mode,
              hostId: hostId,
            ),
            AnimationType.slideUp,
          ),
        );
      },
      borderRadius: BorderRadius.circular(QuizBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(QuizSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          borderRadius: BorderRadius.circular(QuizBorderRadius.md),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(QuizSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: QuizSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: QuizSpacing.xs),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Example function to show the mode selection sheet
/// Call this from your quiz detail page or library
void showModeSelection({
  required BuildContext context,
  required String quizId,
  required String quizTitle,
  required String hostId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.primary.withValues(alpha: 0.3),
    builder:
        (context) => ModeSelectionSheet(
          quizId: quizId,
          quizTitle: quizTitle,
          hostId: hostId,
        ),
  );
}
