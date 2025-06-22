import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/LibrarySection/services/library_service.dart';

class ItemCard extends StatelessWidget {
  final QuizLibraryItem quiz;
  final VoidCallback onTap;

  const ItemCard({Key? key, required this.quiz, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 160,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: quiz.coverImagePath != null
                    ? Image.network(
                        quiz.coverImagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                    : _buildDefaultIcon(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                quiz.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
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
        child: Icon(Icons.quiz_rounded, size: 48, color: AppColors.iconInactive),
      ),
    );
  }
}
