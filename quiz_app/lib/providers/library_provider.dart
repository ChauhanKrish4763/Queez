import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/services/quiz_service.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  /// Fetch usernames from Firestore for originalOwner (batched for performance)
  Future<void> _fetchUsernames(List<QuizLibraryItem> quizzes) async {
    final firestore = FirebaseFirestore.instance;

    // Collect unique owner IDs
    final uniqueOwnerIds =
        quizzes
            .where(
              (q) => q.originalOwner != null && q.originalOwner!.isNotEmpty,
            )
            .map((q) => q.originalOwner!)
            .toSet()
            .toList();

    if (uniqueOwnerIds.isEmpty) return;

    try {
      // Batch query all usernames at once (max 10 at a time due to Firestore limitation)
      final usernameMap = <String, String>{};

      // Process in chunks of 10 (Firestore whereIn limit)
      for (var i = 0; i < uniqueOwnerIds.length; i += 10) {
        final chunk = uniqueOwnerIds.skip(i).take(10).toList();

        final userDocs =
            await firestore
                .collection('users')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();

        for (var doc in userDocs.docs) {
          final username = doc.data()['username'] as String?;
          if (username != null) {
            usernameMap[doc.id] = username;
          }
        }
      }

      // Update all quizzes with fetched usernames
      for (var i = 0; i < quizzes.length; i++) {
        final quiz = quizzes[i];
        if (quiz.originalOwner != null &&
            usernameMap.containsKey(quiz.originalOwner)) {
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
            originalOwnerUsername: usernameMap[quiz.originalOwner]!,
            sharedMode: quiz.sharedMode,
          );
        }
      }
    } catch (e) {
      debugPrint('Error batch fetching usernames: $e');
      // Continue without usernames on error
    }
  }

  /// Reload library from server
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
