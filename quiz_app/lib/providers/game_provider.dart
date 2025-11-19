import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/multiplayer_models.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/websocket_service.dart';

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);

class GameNotifier extends Notifier<GameState> {
  late final WebSocketService _wsService;
  Timer? _timer;

  @override
  GameState build() {
    _wsService = ref.watch(webSocketServiceProvider);
    _wsService.messageStream.listen((message) {
      _handleMessage(message);
    });
    
    ref.onDispose(() {
      _stopTimer();
    });
    
    return const GameState();
  }

  void submitAnswer(dynamic answer) {
    if (state.hasAnswered) return;

    _wsService.sendMessage('submit_answer', {
      'answer': answer,
      'timestamp': DateTime.now().toIso8601String(),
    });

    state = state.copyWith(hasAnswered: true);
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final payload = message['payload'];

    if (type == 'question') {
      _startTimer(payload['time_remaining'] ?? 30);
      state = state.copyWith(
        currentQuestion: payload['question'],
        questionIndex: payload['index'],
        totalQuestions: payload['total'],
        timeRemaining: payload['time_remaining'] ?? 30,
        hasAnswered: false,
        isCorrect: null,
        pointsEarned: null,
        correctAnswer: null,
        rankings: null,
      );
    } else if (type == 'answer_result') {
      state = state.copyWith(
        isCorrect: payload['is_correct'],
        pointsEarned: payload['points'],
      );
    } else if (type == 'answer_reveal') {
      _stopTimer();
      state = state.copyWith(
        correctAnswer: payload['correct_answer'],
        rankings: List<Map<String, dynamic>>.from(payload['rankings']),
      );
    } else if (type == 'quiz_completed') {
      _stopTimer();
      state = state.copyWith(
        rankings: List<Map<String, dynamic>>.from(payload['final_rankings']),
      );
    }
  }

  void _startTimer(int duration) {
    _stopTimer();
    state = state.copyWith(timeRemaining: duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
