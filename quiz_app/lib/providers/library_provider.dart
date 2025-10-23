import 'package:firebase_auth/firebase_auth.dart';
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
      return quizzesData.map((data) => QuizLibraryItem.fromJson(data)).toList();
    } else {
      // Return an empty list if not logged in.
      return [];
    }
  }

  /// Reload library from server
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
