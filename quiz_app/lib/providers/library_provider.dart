import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:quiz_app/LibrarySection/services/unified_library_service.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/LibrarySection/models/library_item.dart';

part 'library_provider.g.dart';

/// Provider for unified library items (quizzes + flashcards)
@riverpod
class QuizLibrary extends _$QuizLibrary {
  @override
  Future<List<LibraryItem>> build() async {
    // Depend on the auth state. If the user logs out, this will auto-rebuild.
    final authState = ref.watch(appAuthProvider);
    final user = FirebaseAuth.instance.currentUser;

    // Only fetch if the user is logged in.
    if (authState.value?.loggedIn == true && user != null) {
      final items = await UnifiedLibraryService.getUnifiedLibrary(user.uid);

      // Fetch usernames from Firestore for items with originalOwner
      await _fetchUsernames(items);

      return items;
    } else {
      // Return an empty list if not logged in.
      return [];
    }
  }

  /// Fetch usernames from Firestore for originalOwner
  Future<void> _fetchUsernames(List<LibraryItem> items) async {
    final firestore = FirebaseFirestore.instance;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.originalOwner != null && item.originalOwner!.isNotEmpty) {
        try {
          final userDoc =
              await firestore.collection('users').doc(item.originalOwner).get();

          if (userDoc.exists) {
            final username = userDoc.data()?['username'] as String?;
            // Create a new instance with the username
            items[i] = LibraryItem(
              id: item.id,
              type: item.type,
              title: item.title,
              description: item.description,
              coverImagePath: item.coverImagePath,
              createdAt: item.createdAt,
              itemCount: item.itemCount,
              category: item.category,
              language: item.language,
              originalOwner: item.originalOwner,
              originalOwnerUsername: username ?? 'Unknown User',
              sharedMode: item.sharedMode,
            );
          }
        } catch (e) {
          print('Error fetching username for ${item.originalOwner}: $e');
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
