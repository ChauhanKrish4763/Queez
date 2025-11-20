import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/multiplayer_models.dart';
import 'package:quiz_app/services/websocket_service.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

final sessionProvider = NotifierProvider<SessionNotifier, SessionState?>(SessionNotifier.new);

final currentUserProvider = NotifierProvider<CurrentUserNotifier, String?>(CurrentUserNotifier.new);

class CurrentUserNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void setUser(String userId) {
    state = userId;
  }
}

final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.connectionStatusStream;
});

class SessionNotifier extends Notifier<SessionState?> {
  late final WebSocketService _wsService;
  Completer<void>? _joinCompleter;

  @override
  SessionState? build() {
    _wsService = ref.watch(webSocketServiceProvider);
    _wsService.messageStream.listen((message) {
      _handleMessage(message);
    });
    return null;
  }

  Future<void> joinSession(String sessionCode, String userId, String username) async {
    debugPrint('🔍 FLUTTER - Joining with username: "$username", userId: $userId');
    _joinCompleter = Completer<void>();
    
    ref.read(currentUserProvider.notifier).setUser(userId);
    await _wsService.connect(sessionCode, userId);
    
    // Send join message
    _wsService.sendMessage('join', {
      'session_code': sessionCode,
      'user_id': userId,
      'username': username,
    });
    
    // Wait for session_state response (with timeout)
    try {
      await _joinCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Failed to join session: timeout waiting for server response');
        },
      );
    } catch (e) {
      _joinCompleter = null;
      rethrow;
    }
  }

  void startQuiz() {
    _wsService.sendMessage('start_quiz');
  }

  void endQuiz() {
    _wsService.sendMessage('end_quiz');
  }

  final StreamController<String> _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final payload = message['payload'];

    if (type == 'error') {
      final errorMessage = payload['message'] ?? 'An unknown error occurred';
      _errorController.add(errorMessage);
      // Complete join with error if waiting
      if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
        _joinCompleter!.completeError(Exception(errorMessage));
        _joinCompleter = null;
      }
    } else if (type == 'session_state') {
      state = SessionState.fromJson(payload);
      // Complete join successfully if waiting
      if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
        _joinCompleter!.complete();
        _joinCompleter = null;
      }
    } else if (type == 'session_update') {
      if (state != null) {
        state = state!.copyWith(
          status: payload['status'],
          participantCount: payload['participant_count'],
          participants: (payload['participants'] as List)
              .map((e) => Participant.fromJson(e))
              .toList(),
        );
      }
    } else if (type == 'quiz_started') {
       if (state != null) {
        state = state!.copyWith(status: 'active');
      }
    } else if (type == 'quiz_completed') {
       if (state != null) {
        state = state!.copyWith(status: 'completed');
      }
    }
  }
}
