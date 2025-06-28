// lib/services/quiz_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:quiz_app/CreateSection/models/question.dart';
import '../models/quiz.dart';

class QuizService {
  static const String baseUrl =
      'http://<YOUR-IP-ADDRESS>:8000'; // Replace with your FastAPI URL

  static Future<String> createQuiz(Quiz quiz) async {
    try {
      print('Starting quiz creation...');
      print('Quiz data: ${quiz.toJson()}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/quizzes'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(quiz.toJson()),
          )
          .timeout(
            Duration(seconds: 30), // Add timeout to prevent infinite waiting
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check for successful status codes (200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);

          // Ensure the response has an 'id' field
          if (data['id'] == null) {
            throw Exception('Server response missing quiz ID');
          }

          final quizId = data['id'].toString();
          print('Quiz created successfully with ID: $quizId');
          return quizId;
        } catch (e) {
          print('JSON parsing error: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        print('Failed with status code: ${response.statusCode}');
        throw Exception(
          'Server error (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('Network error: $e');
      throw Exception(
        'Network error. Please check your internet connection and server status.',
      );
    } on FormatException catch (e) {
      print('JSON format error: $e');
      throw Exception('Invalid response format from server');
    } on Exception catch (e) {
      print('Exception: $e');
      rethrow; // Re-throw custom exceptions as-is
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  static Future<Quiz> getQuiz(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/quizzes/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quiz.fromJson(data);
      } else {
        throw Exception(
          'Failed to get quiz (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      throw Exception('Error getting quiz: $e');
    }
  }

  static Future<List<Question>> fetchQuestionsByQuizId(String quizId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/quizzes/$quizId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final questionsJson = data['questions'] as List<dynamic>;
        return questionsJson.map((q) => Question.fromJson(q)).toList();
      } else {
        throw Exception(
          'Failed to fetch quiz (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }

    
  }
}
