import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/screens/flashcard_play_screen_new.dart';
import 'package:quiz_app/CreateSection/screens/note_viewer_page.dart';
import 'package:quiz_app/LibrarySection/PlaySection/screens/quiz_play_screen.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';
import 'package:quiz_app/LibrarySection/screens/mode_selection_sheet.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/widgets/wait_screen.dart';
import 'package:quiz_app/CreateSection/services/flashcard_service.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';

class ItemCard extends StatelessWidget {
  final LibraryItem item;
  final VoidCallback onDelete;

  const ItemCard({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Soft red color for icon background
    final Color softRed = AppColors.error.withValues(alpha: 0.1);

    // Check if this item was shared in a restrictive mode (only for quizzes)
    final isRestrictiveMode =
        item.isQuiz &&
        (item.sharedMode == 'self_paced' ||
            item.sharedMode == 'timed_individual');

    // Show full features if:
    // 1. No sharedMode (item was created by user, not added via code)
    // 2. sharedMode is 'share' or 'live_multiplayer' (non-restrictive sharing)
    // 3. Item is a flashcard (flashcards don't have sharing restrictions)
    final showFullFeatures = !isRestrictiveMode;

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
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
            // Top Row: Type label + Question count (left) and createdAt + Trash icon (right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: QuizSpacing.md, vertical: QuizSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: QuizSpacing.sm,
                      vertical: QuizSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color:
                          item.isQuiz
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : item.isNote
                              ? AppColors.warning.withValues(alpha: 0.15)
                              : AppColors.accentBright.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
                    ),
                    child: Text(
                      item.isQuiz
                          ? 'QUIZ'
                          : item.isNote
                          ? 'NOTE'
                          : 'FLASHCARD SET',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            item.isQuiz
                                ? AppColors.primary
                                : item.isNote
                                ? AppColors.warning
                                : AppColors.accentBright,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Question count and date row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Question/Card count tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: QuizSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.isQuiz
                                  ? Icons.quiz_outlined
                                  : item.isNote
                                  ? Icons.description_outlined
                                  : Icons.style_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.isNote
                                  ? 'Note'
                                  : '${item.itemCount} ${item.isQuiz ? 'Questions' : 'Cards'}',
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
                            item.createdAt ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Trash icon
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(QuizBorderRadius.circular),
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
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Cover Image
            Container(
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: QuizSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
                child:
                    item.coverImagePath != null
                        ? Image.network(
                          item.coverImagePath!,
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
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(QuizSpacing.lg, QuizSpacing.md, QuizSpacing.lg, 0),
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Author info (if available)
            if (item.originalOwnerUsername != null &&
                item.originalOwnerUsername!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(QuizSpacing.lg, QuizSpacing.sm, QuizSpacing.lg, 0),
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
                        item.originalOwnerUsername!,
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
              padding: const EdgeInsets.fromLTRB(QuizSpacing.lg, QuizSpacing.sm, QuizSpacing.lg, QuizSpacing.lg),
              child: Text(
                item.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Buttons - Different layout for Quiz vs Flashcard vs Note
            Padding(
              padding: const EdgeInsets.fromLTRB(QuizSpacing.lg, 0, QuizSpacing.lg, QuizSpacing.lg),
              child:
                  item.isNote
                      ? // Notes: Only View button (full width)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              Note? loadedNote;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => WaitScreen(
                                        loadingMessage: 'Loading note',
                                        onLoadComplete: () async {
                                          // Preload note and store it
                                          loadedNote =
                                              await NoteService.getNote(
                                                item.id,
                                                user.uid,
                                              );
                                        },
                                        onNavigate: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => NoteViewerPage(
                                                    noteId: item.id,
                                                    userId: user.uid,
                                                    preloadedNote: loadedNote,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.visibility,
                            size: 20,
                            color: AppColors.white,
                          ),
                          label: const Text(
                            'View',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                            ),
                          ),
                        ),
                      )
                      : item.isFlashcard
                      ? // Flashcards: Only Play button (full width)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              dynamic loadedFlashcardSet;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => WaitScreen(
                                        loadingMessage: 'Loading flashcards',
                                        onLoadComplete: () async {
                                          // Preload flashcard set and store it
                                          loadedFlashcardSet =
                                              await FlashcardService.getFlashcardSet(
                                                item.id,
                                                user.uid,
                                              );
                                        },
                                        onNavigate: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      FlashcardPlayScreen(
                                                        flashcardSetId: item.id,
                                                        preloadedFlashcardSet:
                                                            loadedFlashcardSet,
                                                      ),
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              );
                            }
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
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                      : // Quizzes: Share + Play or just Play
                      showFullFeatures
                      ? Row(
                        children: [
                          // Share Button (only for quizzes with full features)
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
                                    quizId: item.id,
                                    quizTitle: item.title,
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
                                    borderRadius: BorderRadius.circular(QuizBorderRadius.md),
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
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    dynamic loadedQuestions;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => WaitScreen(
                                              loadingMessage: 'Loading quiz',
                                              onLoadComplete: () async {
                                                // Preload quiz questions and store them
                                                loadedQuestions =
                                                    await QuizService.fetchQuestionsByQuizId(
                                                      item.id,
                                                      user.uid,
                                                    );
                                              },
                                              onNavigate: () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  customRoute(
                                                    QuizPlayScreen(
                                                      quizItem:
                                                          QuizLibraryItem.fromJson(
                                                            item.toQuizLibraryItem(),
                                                          ),
                                                      preloadedQuestions:
                                                          loadedQuestions,
                                                    ),
                                                    AnimationType.slideUp,
                                                  ),
                                                );
                                              },
                                            ),
                                      ),
                                    );
                                  }
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
                                  backgroundColor: AppColors.primary,
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
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              dynamic loadedQuestions;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => WaitScreen(
                                        loadingMessage: 'Loading quiz',
                                        onLoadComplete: () async {
                                          // Preload quiz questions and store them
                                          loadedQuestions =
                                              await QuizService.fetchQuestionsByQuizId(
                                                item.id,
                                                user.uid,
                                              );
                                        },
                                        onNavigate: () {
                                          Navigator.pushReplacement(
                                            context,
                                            customRoute(
                                              QuizPlayScreen(
                                                quizItem:
                                                    QuizLibraryItem.fromJson(
                                                      item.toQuizLibraryItem(),
                                                    ),
                                                preloadedQuestions:
                                                    loadedQuestions,
                                              ),
                                              AnimationType.slideUp,
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              );
                            }
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
                            backgroundColor: AppColors.primary,
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
