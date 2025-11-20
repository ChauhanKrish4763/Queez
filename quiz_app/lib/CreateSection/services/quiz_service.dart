// lib/services/quiz_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/CreateSection/models/question.dart';

import '../models/quiz.dart';

class QuizService {
  static const String baseUrl =
      'https://transmitted-exhaust-prior-missed.trycloudflare.com'; // Public tunnel URL

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Bypass-Tunnel-Reminder': 'true', // THIS IS CRITICAL
  };

  static Future<String> createQuiz(Quiz quiz) async {
    try {
      debugPrint('Starting quiz creation...');
      debugPrint('Quiz data: ${quiz.toJson()}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/quizzes'),
            headers: _headers,
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

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // Check for successful status codes (200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);

          // Ensure the response has an 'id' field
          if (data['id'] == null) {
            throw Exception('Server response missing quiz ID');
          }

          final quizId = data['id'].toString();
          debugPrint('Quiz created successfully with ID: $quizId');
          return quizId;
        } catch (e) {
          debugPrint('JSON parsing error: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        debugPrint('Failed with status code: ${response.statusCode}');
        throw Exception(
          'Server error (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      debugPrint('Network error');
      throw Exception(
        'Network error. Please check your internet connection and server status.',
      );
    } on FormatException catch (e) {
      debugPrint('JSON format error: $e');
      throw Exception('Invalid response format from server');
    } on Exception catch (e) {
      debugPrint('Exception: $e');
      rethrow; // Re-throw custom exceptions as-is
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  static Future<Quiz> getQuiz(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/quizzes/$id'), headers: _headers)
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
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      throw Exception('Error getting quiz: $e');
    }
  }

  static Future<List<Question>> fetchQuestionsByQuizId(
    String quizId,
    String userId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/quizzes/$quizId?user_id=$userId'),
            headers: _headers,
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
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchQuizzesByCreator(
    String userId,
  ) async {
    try {
      debugPrint('Fetching quizzes for user: $userId');
      final response = await http
          .get(Uri.parse('$baseUrl/quizzes/library/$userId'), headers: _headers)
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      debugPrint('Library response status: ${response.statusCode}');
      debugPrint('Library response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
      } else {
        throw Exception(
          'Failed to fetch quizzes (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      debugPrint('Error fetching quizzes: $e');
      throw Exception('Error fetching quizzes: $e');
    }
  }

  static Future<bool> deleteQuiz(String quizId) async {
    try {
      debugPrint('Deleting quiz: $quizId');
      final response = await http
          .delete(Uri.parse('$baseUrl/quizzes/$quizId'), headers: _headers)
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      debugPrint('Delete response status: ${response.statusCode}');
      debugPrint('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Quiz not found');
      } else {
        throw Exception(
          'Failed to delete quiz (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      debugPrint('Error deleting quiz: $e');
      throw Exception('Error deleting quiz: $e');
    }
  }

  static Future<Map<String, dynamic>> addQuizToLibrary(
    String userId,
    String quizCode,
  ) async {
    try {
      debugPrint(
        'Adding quiz to library for user: $userId with code: $quizCode',
      );
      final response = await http
          .post(
            Uri.parse('$baseUrl/quizzes/add-to-library'),
            headers: _headers,
            body: jsonEncode({'user_id': userId, 'quiz_code': quizCode}),
          )
          .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      debugPrint('Add to library response status: ${response.statusCode}');
      debugPrint('Add to library response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Quiz code not found or session expired');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Invalid quiz code');
      } else {
        throw Exception(
          'Failed to add quiz (${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      debugPrint('Error adding quiz to library: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error adding quiz to library: $e');
    }
  }
}
