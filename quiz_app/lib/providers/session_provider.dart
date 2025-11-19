import 'dart:async';
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

  @override
  SessionState? build() {
    _wsService = ref.watch(webSocketServiceProvider);
    _wsService.messageStream.listen((message) {
      _handleMessage(message);
    });
    return null;
  }

  Future<void> joinSession(String sessionCode, String userId, String username) async {
    ref.read(currentUserProvider.notifier).setUser(userId);
    await _wsService.connect(sessionCode, userId);
    
    // Send join message
    _wsService.sendMessage('join', {
      'session_code': sessionCode,
      'user_id': userId,
      'username': username,
    });
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
      _errorController.add(payload['message'] ?? 'An unknown error occurred');
    } else if (type == 'session_state') {
      state = SessionState.fromJson(payload);
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
