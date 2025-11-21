import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/multiplayer_models.dart';
import 'package:quiz_app/services/websocket_service.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

final sessionProvider = NotifierProvider<SessionNotifier, SessionState?>(
  SessionNotifier.new,
);

final currentUserProvider = NotifierProvider<CurrentUserNotifier, String?>(
  CurrentUserNotifier.new,
);

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

  Future<void> joinSession(
    String sessionCode,
    String userId,
    String username,
  ) async {
    debugPrint('🔍 Joining session $sessionCode as $username');
    _joinCompleter = Completer<void>();

    ref.read(currentUserProvider.notifier).setUser(userId);

    debugPrint('📡 Connecting to WebSocket...');
    await _wsService.connect(sessionCode, userId);

    // Wait for connection to stabilize through ngrok
    debugPrint('⏸️ Waiting for connection to stabilize...');
    await Future.delayed(const Duration(milliseconds: 1000));

    debugPrint('📤 Sending join message...');
    // Send join message ONCE
    _wsService.sendMessage('join', {
      'session_code': sessionCode,
      'user_id': userId,
      'username': username,
    });

    debugPrint('⏳ Waiting for server response...');
    // Wait for session_state response
    try {
      await _joinCompleter!.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('⏰ Join timeout - checking if we have any state...');
          // If we received session_update but not session_state, that's okay
          if (state != null) {
            debugPrint('✅ Have state from session_update, proceeding');
            return;
          }
          throw TimeoutException(
            'Connection timeout. Please check your internet and try again.',
          );
        },
      );
      debugPrint('✅ Joined session successfully');
    } catch (e) {
      debugPrint('❌ Join failed: $e');
      _joinCompleter = null;
      rethrow;
    }
  }

  void startQuiz() {
    debugPrint('🚀 HOST - Sending start_quiz message');
    if (!_wsService.isConnected) {
      debugPrint('⚠️ HOST - WebSocket not connected! Cannot start quiz.');
      _errorController.add('Not connected to session. Please refresh.');
      return;
    }
    _wsService.sendMessage('start_quiz');
  }

  void endQuiz() {
    _wsService.sendMessage('end_quiz');
  }

  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final payload = message['payload'];

    debugPrint('📨 FLUTTER - Received message type: $type');

    if (type == 'error') {
      final errorMessage = payload['message'] ?? 'An unknown error occurred';
      debugPrint('❌ FLUTTER - Error received: $errorMessage');
      _errorController.add(errorMessage);
      // Complete join with error if waiting
      if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
        final completer = _joinCompleter;
        _joinCompleter = null;
        completer?.completeError(Exception(errorMessage));
      }
    } else if (type == 'session_state') {
      debugPrint('✅ FLUTTER - Session state received, completing join');
      debugPrint('📦 Raw payload: $payload');
      try {
        state = SessionState.fromJson(payload);
        debugPrint('✅ Successfully parsed SessionState');
        // Complete join successfully if waiting
        if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
          final completer = _joinCompleter;
          _joinCompleter = null;
          completer?.complete();
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Failed to parse session_state: $e');
        debugPrint('Stack trace: $stackTrace');
        if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
          final completer = _joinCompleter;
          _joinCompleter = null;
          completer?.completeError(e);
        }
      }
    } else if (type == 'session_update') {
      debugPrint('🔄 FLUTTER - Session update received');

      if (state != null) {
        // Update existing state
        state = state!.copyWith(
          status: payload['status'],
          participantCount: payload['participant_count'],
          participants:
              (payload['participants'] as List)
                  .map((e) => Participant.fromJson(e))
                  .toList(),
        );
      }

      // If we're waiting for join confirmation, session_update means we're in
      if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
        if (state == null) {
          debugPrint(
            '✅ FLUTTER - Session update received, waiting for full state...',
          );
        } else {
          debugPrint('✅ FLUTTER - Join confirmed with session_update');
          final completer = _joinCompleter;
          _joinCompleter = null;
          completer?.complete();
        }
      }
    } else if (type == 'quiz_started') {
      debugPrint('🚀 FLUTTER - Quiz started');
      if (state != null) {
        state = state!.copyWith(status: 'active');
      }
    } else if (type == 'quiz_completed' || type == 'quiz_ended') {
      debugPrint('🏁 FLUTTER - Quiz completed');
      if (state != null) {
        state = state!.copyWith(status: 'completed');
      }
    }
    // ✅ REMOVED: Don't handle 'question', 'answer_result', etc. here
    // Let game_provider handle those
  }
}
