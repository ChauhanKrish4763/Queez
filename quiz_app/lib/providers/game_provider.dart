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
    if (state.hasAnswered) {
      debugPrint('⚠️ GAME_PROVIDER - Already answered, ignoring');
      return;
    }

    debugPrint('📤 GAME_PROVIDER - Submitting answer: $answer');
    _wsService.sendMessage('submit_answer', {
      'answer': answer,
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
    });

    state = state.copyWith(hasAnswered: true, selectedAnswer: answer);
    debugPrint('✅ GAME_PROVIDER - Answer submitted, hasAnswered=true');
  }

  void showLeaderboard() {
    debugPrint('🏆 GAME_PROVIDER - Showing leaderboard popup');
    state = state.copyWith(showingLeaderboard: true);
  }

  void hideLeaderboard() {
    debugPrint('🏆 GAME_PROVIDER - Hiding leaderboard popup');
    state = state.copyWith(showingLeaderboard: false);
  }

  void requestNextQuestion() {
    debugPrint('➡️ GAME_PROVIDER - Requesting next question from backend');
    // Send request to backend for next question
    _wsService.sendMessage('request_next_question', {});
    // Reset state for next question
    state = state.copyWith(
      hasAnswered: false,
      selectedAnswer: null,
      isCorrect: null,
      correctAnswer: null,
      pointsEarned: null,
      showingLeaderboard: false,
    );
    debugPrint('✅ GAME_PROVIDER - State reset for next question');
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
        showingLeaderboard: false,
      );
      debugPrint(
        '✅ GAME_PROVIDER - State updated, currentQuestion is now: ${state.currentQuestion != null ? "SET" : "NULL"}',
      );
    } else if (type == 'answer_result') {
      // Handle answer result - just update state, no overlays
      final isCorrect = payload['is_correct'] as bool? ?? false;
      final points = payload['points'] as int? ?? 0;
      final correctAnswer = payload['correct_answer'];
      final newScore = payload['new_total_score'] as int? ?? state.currentScore;

      debugPrint('✅ GAME_PROVIDER - Answer result: ${isCorrect ? "CORRECT" : "INCORRECT"}');
      debugPrint('💰 GAME_PROVIDER - Points earned: $points, New score: $newScore');
      debugPrint('🎯 GAME_PROVIDER - Correct answer was: $correctAnswer');

      state = state.copyWith(
        isCorrect: isCorrect,
        correctAnswer: correctAnswer,
        pointsEarned: points,
        currentScore: newScore,
      );
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
      );
    } else if (type == 'leaderboard_update') {
      // Update leaderboard and show popup
      final leaderboard = payload['leaderboard'];

      debugPrint('🏆 GAME_PROVIDER - Leaderboard update received');

      if (leaderboard != null) {
        final rankings =
            leaderboard is List
                ? List<Map<String, dynamic>>.from(
                  leaderboard.map((item) => Map<String, dynamic>.from(item)),
                )
                : null;

        if (rankings != null) {
          debugPrint('📊 GAME_PROVIDER - ${rankings.length} participants in leaderboard');
          for (var i = 0; i < rankings.length && i < 3; i++) {
            debugPrint('   ${i + 1}. ${rankings[i]['username']}: ${rankings[i]['score']} pts');
          }
          
          // Don't show leaderboard popup on last question
          final isLastQuestion = state.questionIndex + 1 >= state.totalQuestions;
          debugPrint('🔍 GAME_PROVIDER - Is last question? $isLastQuestion (${state.questionIndex + 1} >= ${state.totalQuestions})');
          
          state = state.copyWith(
            rankings: rankings,
            showingLeaderboard: !isLastQuestion,
          );
          
          if (isLastQuestion) {
            debugPrint('🏁 GAME_PROVIDER - Last question! NOT showing leaderboard popup');
          } else {
            debugPrint('✅ GAME_PROVIDER - Leaderboard popup will be shown');
          }
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
      debugPrint('🏁 GAME_PROVIDER - Quiz completed!');
      _stopTimer();

      final finalRankings = payload['final_rankings'] ?? payload['results'];
      if (finalRankings != null) {
        final rankings = List<Map<String, dynamic>>.from(
          finalRankings.map((item) => Map<String, dynamic>.from(item)),
        );
        debugPrint('📊 GAME_PROVIDER - Final rankings: ${rankings.length} participants');
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
