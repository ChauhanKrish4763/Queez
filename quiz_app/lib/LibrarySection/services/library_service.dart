import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quiz_app/LibrarySection/widgets/quiz_library_item.dart';

class LibraryService {
  static const String baseUrl =
      'https://recruiting-transmitted-including-garbage.trycloudflare.com '; // Public tunnel URL

  static Future<List<QuizLibraryItem>> fetchQuizLibrary() async {
    final response = await http.get(Uri.parse('$baseUrl/quizzes/library'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> quizzesJson = data['data'];
        return quizzesJson
            .map((json) => QuizLibraryItem.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load quizzes');
      }
    } else {
      throw Exception('Failed to load quizzes: ${response.reasonPhrase}');
    }
  }
}
