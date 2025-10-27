import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/LibrarySection/LiveMode/screens/live_multiplayer_dashboard.dart';
import 'package:quiz_app/LibrarySection/screens/library_page.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

void showAddQuizModal(
  BuildContext context,
  Future<void> Function() onQuizAdded,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddQuizModalContent(onQuizAdded: onQuizAdded),
  );
}

class AddQuizModalContent extends StatefulWidget {
  final Future<void> Function() onQuizAdded;

  const AddQuizModalContent({Key? key, required this.onQuizAdded})
    : super(key: key);

  @override
  State<AddQuizModalContent> createState() => _AddQuizModalContentState();
}

class _AddQuizModalContentState extends State<AddQuizModalContent> {
  final TextEditingController _quizCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _quizCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleAddQuiz() async {
    final quizCode = _quizCodeController.text.trim();

    if (quizCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a quiz code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add quiz to user's library via service
      final result = await QuizService.addQuizToLibrary(userId, quizCode);

      if (!mounted) return;

      if (result['mode'] == 'live_multiplayer') {
        // For live multiplayer, open the dashboard without saving
        Navigator.pop(context); // Close the modal
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return PageTransition(
                animation: animation,
                animationType: AnimationType.slideUp,
                child: LiveMultiplayerDashboard(
                  quizId: result['quiz_id'],
                  sessionCode: quizCode,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        // For self-paced and timed_individual, the quiz is saved
        final quizTitle = result['quiz_title'] ?? 'Quiz';

        // Close the modal first
        Navigator.pop(context);

        // Show success dialog (without auto-dismiss callback)
        final dialogContext = context;

        // Show the dialog but don't wait for it
        QuizSavedDialog.show(
          dialogContext,
          title: 'Success!',
          message: 'Quiz "$quizTitle" has been added to your library!',
          onDismiss: () {
            // This will be called when dialog auto-dismisses
          },
        );

        // Reload quizzes from server in background
        await widget.onQuizAdded();

        // Sleep for half a second
        await Future.delayed(const Duration(milliseconds: 500));

        // Set the search query to the quiz title
        LibraryPage.setSearchQuery(quizTitle);

        // Close the dialog after setting search
        if (Navigator.canPop(dialogContext)) {
          Navigator.of(dialogContext).pop();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Add a quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Add a quiz made by other users',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Text field
              TextField(
                controller: _quizCodeController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Enter quiz code',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  errorText: _errorMessage,
                  errorStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
                onSubmitted: (_) => _handleAddQuiz(),
              ),
              const SizedBox(height: 24),

              // Add button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAddQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                              strokeWidth: 2.5,
                            ),
                          )
                          : const Text(
                            'Add Quiz',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
