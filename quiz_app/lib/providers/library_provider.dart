import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';

part 'library_provider.g.dart';

/// Provider for quiz library items
@riverpod
class QuizLibrary extends _$QuizLibrary {
  @override
  Future<List<QuizLibraryItem>> build() async {
    // Depend on the auth state. If the user logs out, this will auto-rebuild.
    final authState = ref.watch(appAuthProvider);
    final user = FirebaseAuth.instance.currentUser;

    // Only fetch if the user is logged in.
    if (authState.value?.loggedIn == true && user != null) {
      final quizzesData = await QuizService.fetchQuizzesByCreator(user.uid);
      final quizzes =
          quizzesData.map((data) => QuizLibraryItem.fromJson(data)).toList();

      // Fetch usernames from Firestore for quizzes with originalOwner
      await _fetchUsernames(quizzes);

      return quizzes;
    } else {
      // Return an empty list if not logged in.
      return [];
    }
  }

  /// Fetch usernames from Firestore for originalOwner
  Future<void> _fetchUsernames(List<QuizLibraryItem> quizzes) async {
    final firestore = FirebaseFirestore.instance;

    for (var i = 0; i < quizzes.length; i++) {
      final quiz = quizzes[i];
      if (quiz.originalOwner != null && quiz.originalOwner!.isNotEmpty) {
        try {
          final userDoc =
              await firestore.collection('users').doc(quiz.originalOwner).get();

          if (userDoc.exists) {
            final username = userDoc.data()?['username'] as String?;
            // Create a new instance with the username
            quizzes[i] = QuizLibraryItem(
              id: quiz.id,
              title: quiz.title,
              description: quiz.description,
              coverImagePath: quiz.coverImagePath,
              createdAt: quiz.createdAt,
              questionCount: quiz.questionCount,
              language: quiz.language,
              category: quiz.category,
              originalOwner: quiz.originalOwner,
              originalOwnerUsername: username ?? 'Unknown User',
              sharedMode: quiz.sharedMode, // IMPORTANT: Preserve the sharedMode
            );
          }
        } catch (e) {
          print('Error fetching username for ${quiz.originalOwner}: $e');
        }
      }
    }
  }

  /// Reload library from server
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
