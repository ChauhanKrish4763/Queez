import 'package:flutter/material.dart';
import 'package:quiz_app/LibrarySection/widgets/item_card.dart';
import 'package:quiz_app/LibrarySection/widgets/library_body.dart';
import 'package:quiz_app/LibrarySection/services/library_service.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

final GlobalKey<_LibraryPageState> libraryPageKey = GlobalKey<_LibraryPageState>();

class LibraryPage extends StatefulWidget {
  LibraryPage({Key? key}) : super(key: libraryPageKey);

  @override
  State<LibraryPage> createState() => _LibraryPageState();

  /// ✅ Static method to call reload from anywhere
  static void reloadItems() {
    libraryPageKey.currentState?._reloadItems();
  }
}

class _LibraryPageState extends State<LibraryPage> with TickerProviderStateMixin {
  static List<QuizLibraryItem>? _cachedQuizzes;
  List<QuizLibraryItem> quizzes = [];
  List<QuizLibraryItem> filteredQuizzes = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _loadQuizzesOnce();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// 🔁 Called internally and from `reloadItems`
  Future<void> _reloadItems() async {
    _cachedQuizzes = null;
    await _loadQuizzesOnce();
  }

  Future<void> _loadQuizzesOnce() async {
    if (_cachedQuizzes != null) {
      setState(() {
        quizzes = _cachedQuizzes!;
        filteredQuizzes = _cachedQuizzes!;
        isLoading = false;
      });
      _fadeController.forward();
      return;
    }
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final fetchedQuizzes = await LibraryService.fetchQuizLibrary();

      _cachedQuizzes = fetchedQuizzes;
      setState(() {
        quizzes = fetchedQuizzes;
        filteredQuizzes = fetchedQuizzes;
        isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterQuizzes(String query) {
    setState(() {
      searchQuery = query;
      filteredQuizzes = query.isEmpty
          ? quizzes
          : quizzes
              .where((quiz) => quiz.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: buildSearchSection(
              searchQuery: searchQuery,
              onQueryChanged: _filterQuizzes,
            ),
          ),
          buildLibraryBody(
            isLoading: isLoading,
            errorMessage: errorMessage,
            filteredQuizzes: filteredQuizzes,
            searchQuery: searchQuery,
            onRetry: _loadQuizzesOnce,
            onCardTap: (quiz) {
              customNavigate(context, '/assessment_page', AnimationType.slideUp);
            },
          ),
        ],
      ),
    );
  }
}
