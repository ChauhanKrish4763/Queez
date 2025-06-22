import 'package:flutter/material.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/LibrarySection/services/library_service.dart';

Widget buildSearchSection({
  required String searchQuery,
  required ValueChanged<String> onQueryChanged,
}) {
  return Container(
    margin: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search quizzes...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
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
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.iconInactive),
                      onPressed: () => onQueryChanged(''),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
  required bool isLoading,
  required String? errorMessage,
  required List<QuizLibraryItem> filteredQuizzes,
  required String searchQuery,
  required VoidCallback onRetry,
  required void Function(QuizLibraryItem) onCardTap,
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
            Text('Loading your quizzes...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Please wait a moment', style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withOpacity(0.7))),
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
            Text('Oops! Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  return SliverPadding(
    padding: const EdgeInsets.all(20),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: List.generate(
          filteredQuizzes.length,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ItemCard(quiz: filteredQuizzes[index], onTap: () => onCardTap(filteredQuizzes[index])),
          ),
        ),
      ),
    ),
  );
}
