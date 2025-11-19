import 'package:freezed_annotation/freezed_annotation.dart';

part 'multiplayer_models.freezed.dart';
part 'multiplayer_models.g.dart';

@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    required String userId,
    required String username,
    required String joinedAt,
    @Default(true) bool connected,
    @Default(0) int score,
    @Default([]) List<Map<String, dynamic>> answers,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);
}

@freezed
abstract class SessionState with _$SessionState {
  const factory SessionState({
    required String sessionCode,
    required String quizId,
    required String hostId,
    required String status, // waiting, active, completed
    required String mode,
    required int currentQuestionIndex,
    required String quizTitle,
    required int totalQuestions,
    @Default([]) List<Participant> participants,
    @Default(0) int participantCount,
  }) = _SessionState;

  factory SessionState.fromJson(Map<String, dynamic> json) => _$SessionStateFromJson(json);
}

@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    Map<String, dynamic>? currentQuestion,
    @Default(0) int questionIndex,
    @Default(0) int totalQuestions,
    @Default(30) int timeRemaining,
    @Default(false) bool hasAnswered,
    bool? isCorrect,
    int? pointsEarned,
    dynamic correctAnswer,
    List<Map<String, dynamic>>? rankings,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
}

@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required int rank,
    required String userId,
    required int score,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);
}

@freezed
abstract class LeaderboardState with _$LeaderboardState {
  const factory LeaderboardState({
    @Default([]) List<LeaderboardEntry> rankings,
    LeaderboardEntry? currentUserEntry,
  }) = _LeaderboardState;

  factory LeaderboardState.fromJson(Map<String, dynamic> json) => _$LeaderboardStateFromJson(json);
}
