import 'dart:async';

import 'package:flutter/material.dart';
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
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
    });

    state = state.copyWith(hasAnswered: true, selectedAnswer: answer);
  }

  void hideFeedback() {
    state = state.copyWith(showingFeedback: false);
  }

  void showCorrectAnswerHighlight() {
    state = state.copyWith(showingFeedback: false, showingCorrectAnswer: true);
  }

  void hideCorrectAnswerHighlight() {
    state = state.copyWith(showingCorrectAnswer: false);
  }

  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final payload = message['payload'];

    if (type == 'question') {
      // New question received
      debugPrint('📚 GAME_PROVIDER - Processing question message');
      debugPrint('📦 GAME_PROVIDER - Question payload: $payload');
      _startTimer(payload['time_remaining'] ?? 30);
      state = state.copyWith(
        currentQuestion: payload['question'],
        questionIndex: payload['index'],
        totalQuestions: payload['total'],
        timeRemaining: payload['time_remaining'] ?? 30,
        hasAnswered: false,
        selectedAnswer: null,
        isCorrect: null,
        correctAnswer: null,
        pointsEarned: null,
        rankings: null,
        showingFeedback: false,
        showingCorrectAnswer: false,
      );
      debugPrint(
        '✅ GAME_PROVIDER - State updated, currentQuestion is now: ${state.currentQuestion != null ? "SET" : "NULL"}',
      );
    } else if (type == 'answer_result') {
      // ✅ FIXED: Handle answer result with all fields
      final isCorrect = payload['is_correct'] as bool? ?? false;
      final points = payload['points'] as int? ?? 0;
      final correctAnswer = payload['correct_answer'];
      final newScore = payload['new_total_score'] as int? ?? state.currentScore;

      state = state.copyWith(
        isCorrect: isCorrect,
        correctAnswer: correctAnswer,
        pointsEarned: points,
        currentScore: newScore,
        showingFeedback: true,
      );

      // Auto-hide feedback after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (state.showingFeedback) {
          hideFeedback();
        }
      });
    } else if (type == 'answer_feedback') {
      // Handle answer feedback message for participants (alternative message type)
      final isCorrect = payload['is_correct'] as bool? ?? false;
      final pointsEarned = payload['points_earned'] as int? ?? 0;
      final correctAnswer = payload['correct_answer'];
      final yourScore = payload['your_score'] as int? ?? state.currentScore;
      final answerDistribution =
          payload['answer_distribution'] != null
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

      // Auto-hide feedback after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (state.showingFeedback) {
          hideFeedback();
        }
      });
    } else if (type == 'leaderboard_update') {
      // ✅ FIXED: Update leaderboard for all users, not just host
      final leaderboard = payload['leaderboard'];

      if (leaderboard != null) {
        final rankings =
            leaderboard is List
                ? List<Map<String, dynamic>>.from(
                  leaderboard.map((item) => Map<String, dynamic>.from(item)),
                )
                : null;

        if (rankings != null) {
          state = state.copyWith(rankings: rankings);
        }
      }
    } else if (type == 'answer_reveal') {
      // Host reveals answer and shows rankings
      _stopTimer();

      final correctAnswer = payload['correct_answer'];
      final rankings =
          payload['rankings'] != null
              ? List<Map<String, dynamic>>.from(
                payload['rankings'].map(
                  (item) => Map<String, dynamic>.from(item),
                ),
              )
              : null;

      state = state.copyWith(correctAnswer: correctAnswer, rankings: rankings);
    } else if (type == 'quiz_completed' || type == 'quiz_ended') {
      // Quiz finished
      _stopTimer();

      final finalRankings = payload['final_rankings'] ?? payload['results'];
      if (finalRankings != null) {
        final rankings = List<Map<String, dynamic>>.from(
          finalRankings.map((item) => Map<String, dynamic>.from(item)),
        );
        state = state.copyWith(rankings: rankings);
      }
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
