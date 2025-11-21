import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/multiplayer_models.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/services/websocket_service.dart';

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

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

    state = state.copyWith(
      hasAnswered: true,
      selectedAnswer: answer,
    );
  }

  void hideFeedback() {
    state = state.copyWith(showingFeedback: false);
  }

  void showCorrectAnswerHighlight() {
    state = state.copyWith(
      showingFeedback: false,
      showingCorrectAnswer: true,
    );
  }

  void hideCorrectAnswerHighlight() {
    state = state.copyWith(showingCorrectAnswer: false);
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
        showingFeedback: true,
      );
    } else if (type == 'answer_feedback') {
      // Handle answer feedback message for participants
      final isCorrect = payload['is_correct'] as bool;
      final pointsEarned = payload['points_earned'] as int;
      final correctAnswer = payload['correct_answer'];
      final yourScore = payload['your_score'] as int;
      final answerDistribution = payload['answer_distribution'] != null
          ? Map<dynamic, int>.from(payload['answer_distribution'])
          : null;

      state = state.copyWith(
        lastAnswerCorrect: isCorrect,
        isCorrect: isCorrect,
        pointsEarned: pointsEarned,
        correctAnswer: correctAnswer,
        currentScore: yourScore,
        answerDistribution: answerDistribution,
        showingFeedback: true,
      );

      // Start 2-second timer to hide feedback
      Future.delayed(const Duration(seconds: 2), () {
        if (state.showingFeedback) {
          state = state.copyWith(showingFeedback: false);
        }
      });
    } else if (type == 'answer_reveal') {
      _stopTimer();
      state = state.copyWith(
        correctAnswer: payload['correct_answer'],
        rankings: List<Map<String, dynamic>>.from(payload['rankings']),
      );
    } else if (type == 'leaderboard_update') {
      // Realtime leaderboard update for host only
      // Only process if the current user is a host
      if (state.isHost) {
        final rankings = payload['rankings'] != null
            ? List<Map<String, dynamic>>.from(payload['rankings'])
            : null;
        final answerDistribution = payload['answer_distribution'] != null
            ? Map<dynamic, int>.from(payload['answer_distribution'])
            : null;

        state = state.copyWith(
          rankings: rankings,
          answerDistribution: answerDistribution,
        );
      }
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
