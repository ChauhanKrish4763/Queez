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

    // Only mark as answered, don't set selectedAnswer yet (wait for backend response)
    state = state.copyWith(hasAnswered: true);
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
    // DON'T reset state here - let it reset when new question arrives
    // This prevents the flash of old answers before new question loads
    debugPrint('✅ GAME_PROVIDER - Request sent, waiting for new question');
  }

  void requestLeaderboard() {
    debugPrint('🏆 GAME_PROVIDER - Requesting real-time leaderboard from backend');
    _wsService.sendMessage('request_leaderboard', {});
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
      // Handle answer result - update state with user's answer and correctness
      final isCorrect = payload['is_correct'] as bool? ?? false;
      final points = payload['points'] as int? ?? 0;
      final correctAnswer = payload['correct_answer'];
      final newScore = payload['new_total_score'] as int? ?? state.currentScore;
      final questionType = payload['question_type'] as String?;
      
      // Get the user's submitted answer from the payload if available
      final userAnswer = payload['user_answer'];

      debugPrint('✅ GAME_PROVIDER - Answer result: ${isCorrect ? "CORRECT" : "INCORRECT"}');
      debugPrint('💰 GAME_PROVIDER - Points earned: $points, New score: $newScore');
      debugPrint('🎯 GAME_PROVIDER - Correct answer was: $correctAnswer');
      debugPrint('👤 GAME_PROVIDER - User answer was: $userAnswer');
      debugPrint('📝 GAME_PROVIDER - Question type: $questionType');

      state = state.copyWith(
        isCorrect: isCorrect,
        correctAnswer: correctAnswer,
        selectedAnswer: userAnswer,
        pointsEarned: points,
        currentScore: newScore,
      );
      
      // Auto-advance for single choice, true/false, and multi-select after delay
      // Single choice and true/false: 2 seconds
      // Multi-select: 3 seconds (handled in widget, but also here as fallback)
      if (questionType == 'singleMcq' || questionType == 'trueFalse') {
        debugPrint('⏱️ GAME_PROVIDER - Auto-advancing to next question in 2s (single/tf)');
        Future.delayed(const Duration(seconds: 2), () {
          if (state.hasAnswered && state.correctAnswer != null) {
            debugPrint('➡️ GAME_PROVIDER - Auto-requesting next question');
            requestNextQuestion();
          }
        });
      } else if (questionType == 'multiMcq') {
        debugPrint('⏱️ GAME_PROVIDER - Auto-advancing to next question in 3s (multi-select)');
        Future.delayed(const Duration(seconds: 3), () {
          if (state.hasAnswered && state.correctAnswer != null) {
            debugPrint('➡️ GAME_PROVIDER - Auto-requesting next question (multi-select)');
            requestNextQuestion();
          }
        });
      } else if (questionType == 'dragAndDrop') {
        debugPrint('⏱️ GAME_PROVIDER - Auto-advancing to next question in 3s (drag-drop)');
        Future.delayed(const Duration(seconds: 3), () {
          if (state.hasAnswered && state.correctAnswer != null) {
            debugPrint('➡️ GAME_PROVIDER - Auto-requesting next question (drag-drop)');
            requestNextQuestion();
          }
        });
      }
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
      // Update leaderboard - POPUP DISABLED, just update rankings
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
          
          // Update rankings but DON'T show popup (disabled for now)
          state = state.copyWith(
            rankings: rankings,
            showingLeaderboard: false, // DISABLED
          );
          
          debugPrint('✅ GAME_PROVIDER - Rankings updated (popup disabled)');
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
    } else if (type == 'leaderboard_response') {
      // Real-time leaderboard response
      debugPrint('🏆 GAME_PROVIDER - Leaderboard response received');
      final leaderboard = payload['leaderboard'];
      
      if (leaderboard != null) {
        final rankings = List<Map<String, dynamic>>.from(
          leaderboard.map((item) => Map<String, dynamic>.from(item)),
        );
        debugPrint('📊 GAME_PROVIDER - ${rankings.length} participants in real-time leaderboard');
        for (var i = 0; i < rankings.length && i < 3; i++) {
          debugPrint('   ${i + 1}. ${rankings[i]['username']}: ${rankings[i]['score']} pts (Q${rankings[i]['answered_count']}/${rankings[i]['total_questions']})');
        }
        
        state = state.copyWith(rankings: rankings);
        debugPrint('✅ GAME_PROVIDER - Real-time rankings updated');
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
