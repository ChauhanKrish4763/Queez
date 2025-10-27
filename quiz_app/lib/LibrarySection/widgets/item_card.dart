import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/LibrarySection/screens/mode_selection_sheet.dart';
import 'package:quiz_app/LibrarySection/PlaySection/screens/quiz_play_screen.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

class ItemCard extends StatelessWidget {
  final QuizLibraryItem quiz;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const ItemCard({
    Key? key,
    required this.quiz,
    required this.onDelete,
    required this.onView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Soft red color for icon background
    final Color softRed = Colors.red.shade50;

    // Check if this quiz was shared in a restrictive mode (self_paced or timed_individual)
    final isRestrictiveMode =
        quiz.sharedMode == 'self_paced' ||
        quiz.sharedMode == 'timed_individual';

    // Show full features if:
    // 1. No sharedMode (quiz was created by user, not added via code)
    // 2. sharedMode is 'share' or 'live_multiplayer' (non-restrictive sharing)
    // Hide features only if sharedMode is 'self_paced' or 'timed_individual'
    final showFullFeatures = !isRestrictiveMode;

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Question count (left) and createdAt + Trash icon (right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Question count tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.quiz_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${quiz.questionCount}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // CreatedAt and Trash icon
                  Row(
                    children: [
                      // CreatedAt text
                      Text(
                        quiz.createdAt ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Trash icon
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: softRed,
                            border: Border.all(
                              color: Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Cover Image
            Container(
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    quiz.coverImagePath != null
                        ? Image.network(
                          quiz.coverImagePath!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildDefaultIcon(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.primary,
                                  ),
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        )
                        : _buildDefaultIcon(),
              ),
            ),
            // Title and View Icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // View icon (only show if showFullFeatures is true)
                  if (showFullFeatures)
                    IconButton(
                      icon: const Icon(
                        Icons.visibility_rounded,
                        color: AppColors.iconInactive,
                      ),
                      onPressed: onView,
                      tooltip: 'View',
                    ),
                ],
              ),
            ),
            // Author info (if available)
            if (quiz.originalOwnerUsername != null &&
                quiz.originalOwnerUsername!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        quiz.originalOwnerUsername!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            // Description
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Text(
                quiz.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Share and Play Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child:
                  showFullFeatures
                      ? Row(
                        children: [
                          // Share Button (only for showFullFeatures)
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final hostId =
                                      FirebaseAuth.instance.currentUser?.uid ??
                                      'anonymous';
                                  showModeSelection(
                                    context: context,
                                    quizId: quiz.id,
                                    quizTitle: quiz.title,
                                    hostId: hostId,
                                  );
                                },
                                icon: const Icon(
                                  Icons.share,
                                  size: 20,
                                  color: AppColors.white,
                                ),
                                label: const Text(
                                  'Share',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Play Button
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    customRoute(
                                      QuizPlayScreen(quizItem: quiz),
                                      AnimationType.slideUp,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  size: 20,
                                  color: AppColors.white,
                                ),
                                label: const Text(
                                  'Play',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              customRoute(
                                QuizPlayScreen(quizItem: quiz),
                                AnimationType.slideUp,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.play_arrow,
                            size: 20,
                            color: AppColors.white,
                          ),
                          label: const Text(
                            'Play',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.quiz_rounded,
          size: 48,
          color: AppColors.iconInactive,
        ),
      ),
    );
  }
}
