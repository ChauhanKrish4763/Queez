// lib/screens/session_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SessionService {
  static const String baseUrl = 'https://quizapp2024.loca.lt';

  // Create a new quiz session
  static Future<Map<String, dynamic>> createSession({
    required String quizId,
    required String hostId,
    required String mode,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/quiz/$quizId/create-session'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'quiz_id': quizId,
              'host_id': hostId,
              'mode': mode,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? true,
          'session_code': data['session_code'],
          'expires_in': data['expires_in'],
          'expires_at': data['expires_at'],
        };
      } else {
        throw Exception('Failed to create session: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      throw Exception('Error creating session: $e');
    }
  }

  // Get session information
  static Future<Map<String, dynamic>> getSessionInfo(String sessionCode) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/session/$sessionCode'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found or expired');
      } else if (response.statusCode == 410) {
        throw Exception('Session has expired');
      } else {
        throw Exception('Error getting session info: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // Get participant count
  static Future<Map<String, dynamic>> getParticipants(
    String sessionCode,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/session/$sessionCode/participants'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found or expired');
      } else if (response.statusCode == 410) {
        throw Exception('Session has expired');
      } else {
        throw Exception('Error getting participants: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // Join a session
  static Future<Map<String, dynamic>> joinSession({
    required String sessionCode,
    required String userId,
    required String username,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/session/$sessionCode/join'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'username': username}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found or expired');
      } else if (response.statusCode == 410) {
        throw Exception('Session has expired');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Quiz has already started');
      } else {
        throw Exception('Error joining session: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // Start quiz session
  static Future<Map<String, dynamic>> startSession({
    required String sessionCode,
    required String hostId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/session/$sessionCode/start'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'host_id': hostId}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found');
      } else if (response.statusCode == 403) {
        throw Exception('Only the host can start the quiz');
      } else {
        throw Exception('Error starting session: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  // End quiz session
  static Future<Map<String, dynamic>> endSession({
    required String sessionCode,
    required String hostId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/session/$sessionCode/end'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'host_id': hostId}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Session not found');
      } else if (response.statusCode == 403) {
        throw Exception('Only the host can end the quiz');
      } else {
        throw Exception('Error ending session: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }
}
