import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/screens/quiz_details.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

Widget buildSearchSection({
  required String searchQuery,
  required TextEditingController searchController,
  required ValueChanged<String> onQueryChanged,
  required BuildContext context,
  required VoidCallback onAddQuiz,
}) {
  return Container(
    margin: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Library',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            IconButton(
              onPressed: onAddQuiz,
              icon: const Icon(Icons.add, size: 24),
              tooltip: 'Add a quiz',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search quizzes...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.iconInactive,
                  size: 24,
                ),
              ),
              suffixIcon:
                  searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.iconInactive,
                        ),
                        onPressed: () {
                          searchController.clear();
                          onQueryChanged('');
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildLibraryBody({
  required BuildContext context,
  required bool isLoading,
  required String? errorMessage,
  required List<QuizLibraryItem> filteredQuizzes,
  required String searchQuery,
  required VoidCallback onRetry,
}) {
  if (isLoading) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your quizzes...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait a moment',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  if (errorMessage != null) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  if (filteredQuizzes.isEmpty) {
    return SliverFillRemaining(
      child: Center(
        child: Text(
          searchQuery.isNotEmpty ? 'No matches found' : 'No quizzes available',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  return SliverPadding(
    padding: const EdgeInsets.all(20),
    sliver: SliverToBoxAdapter(
      child: _AnimatedQuizList(quizzes: filteredQuizzes),
    ),
  );
}

class _AnimatedQuizList extends StatefulWidget {
  final List<QuizLibraryItem> quizzes;

  const _AnimatedQuizList({required this.quizzes});

  @override
  State<_AnimatedQuizList> createState() => _AnimatedQuizListState();
}

class _AnimatedQuizListState extends State<_AnimatedQuizList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<QuizLibraryItem> _quizzes;

  @override
  void initState() {
    super.initState();
    _quizzes = List.from(widget.quizzes);
  }

  @override
  void didUpdateWidget(_AnimatedQuizList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quizzes.length != _quizzes.length) {
      _quizzes = List.from(widget.quizzes);
    }
  }

  Future<void> _removeItem(int index) async {
    final removedQuiz = _quizzes[index];
    _quizzes.removeAt(index);

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildQuizCard(removedQuiz, animation, index),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildQuizCard(
    QuizLibraryItem quiz,
    Animation<double> animation,
    int index,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ItemCard(
              quiz: quiz,
              onView: () {
                _privateNavigator(context, quiz, AnimationType.fade);
              },
              onDelete: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Delete Quiz'),
                        content: Text(
                          'Are you sure you want to delete "${quiz.title}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                );

                if (confirmed == true) {
                  try {
                    // Delete from backend
                    await QuizService.deleteQuiz(quiz.id);

                    // Remove item with animation
                    await _removeItem(index);

                    // Show success message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quiz deleted successfully'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    // Show error message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete quiz: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _quizzes.length,
      itemBuilder: (context, index, animation) {
        if (index >= _quizzes.length) return const SizedBox.shrink();
        return _buildQuizCard(_quizzes[index], animation, index);
      },
    );
  }
}

void _privateNavigator(
  BuildContext context,
  QuizLibraryItem quizItem,
  AnimationType animationType, {
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  final navigator = navigatorKey?.currentState ?? Navigator.of(context);

  navigator.push(
    PageRouteBuilder(
      settings: RouteSettings(arguments: quizItem),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PageTransition(
          animation: animation,
          animationType: animationType,
          child: QuizDetails(quizItem: quizItem),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}
