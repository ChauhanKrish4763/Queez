// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'multiplayer_models.freezed.dart';
part 'multiplayer_models.g.dart';

@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    @JsonKey(name: 'joined_at') required String joinedAt,
    @Default(true) bool connected,
    @Default(0) int score,
    @Default([]) List<Map<String, dynamic>> answers,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);
}

@freezed
abstract class SessionState with _$SessionState {
  const factory SessionState({
    @JsonKey(name: 'session_code') required String sessionCode,
    @JsonKey(name: 'quiz_id') required String quizId,
    @JsonKey(name: 'host_id') required String hostId,
    required String status,
    required String mode,
    @JsonKey(name: 'current_question_index') required int currentQuestionIndex,
    @JsonKey(name: 'quiz_title') required String quizTitle,
    @JsonKey(name: 'total_questions') required int totalQuestions,
    @Default([]) List<Participant> participants,
    @JsonKey(name: 'participant_count') @Default(0) int participantCount,
  }) = _SessionState;

  factory SessionState.fromJson(Map<String, dynamic> json) => _$SessionStateFromJson(json);
}

@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    @JsonKey(name: 'current_question') Map<String, dynamic>? currentQuestion,
    @JsonKey(name: 'question_index') @Default(0) int questionIndex,
    @JsonKey(name: 'total_questions') @Default(0) int totalQuestions,
    @JsonKey(name: 'time_remaining') @Default(30) int timeRemaining,
    @JsonKey(name: 'has_answered') @Default(false) bool hasAnswered,
    @JsonKey(name: 'is_correct') bool? isCorrect,
    @JsonKey(name: 'points_earned') int? pointsEarned,
    @JsonKey(name: 'correct_answer') dynamic correctAnswer,
    List<Map<String, dynamic>>? rankings,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
}

@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required int rank,
    @JsonKey(name: 'user_id') required String userId,
    required int score,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);
}

@freezed
abstract class LeaderboardState with _$LeaderboardState {
  const factory LeaderboardState({
    @Default([]) List<LeaderboardEntry> rankings,
    @JsonKey(name: 'current_user_entry') LeaderboardEntry? currentUserEntry,
  }) = _LeaderboardState;

  factory LeaderboardState.fromJson(Map<String, dynamic> json) => _$LeaderboardStateFromJson(json);
}
  