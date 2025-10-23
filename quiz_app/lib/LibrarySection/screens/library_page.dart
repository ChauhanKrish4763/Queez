import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/LibrarySection/widgets/library_body.dart';
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/utils/color.dart';

final GlobalKey<_LibraryPageState> libraryPageKey =
    GlobalKey<_LibraryPageState>();

class LibraryPage extends ConsumerStatefulWidget {
  LibraryPage({Key? key}) : super(key: libraryPageKey);

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();

  /// ✅ Static method to call reload from anywhere
  static void reloadItems() {
    libraryPageKey.currentState?._reloadItems();
  }
}

class _LibraryPageState extends ConsumerState<LibraryPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// 🔁 Reload items from server
  Future<void> _reloadItems() async {
    await ref.read(quizLibraryProvider.notifier).reload();
  }

  void _filterQuizzes(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<QuizLibraryItem> _getFilteredQuizzes(List<QuizLibraryItem> allQuizzes) {
    if (_searchQuery.isEmpty) {
      return allQuizzes;
    }

    return allQuizzes.where((quiz) {
      return quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          quiz.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizLibraryProvider);

    // Get filtered quizzes and loading/error state from AsyncValue
    bool isLoading = false;
    String? errorMessage;
    List<QuizLibraryItem> filteredQuizzes = [];

    quizzesAsync.when(
      data: (quizzes) {
        filteredQuizzes = _getFilteredQuizzes(quizzes);
      },
      loading: () {
        isLoading = true;
      },
      error: (error, _) {
        errorMessage = error.toString();
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: buildSearchSection(
              searchQuery: _searchQuery,
              onQueryChanged: _filterQuizzes,
            ),
          ),
          buildLibraryBody(
            context: context,
            isLoading: isLoading,
            errorMessage: errorMessage,
            filteredQuizzes: filteredQuizzes,
            searchQuery: _searchQuery,
            onRetry: _reloadItems,
          ),
        ],
      ),
    );
  }
}
