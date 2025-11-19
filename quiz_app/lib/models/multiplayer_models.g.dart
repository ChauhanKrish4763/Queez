// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multiplayer_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
  userId: json['userId'] as String,
  username: json['username'] as String,
  joinedAt: json['joinedAt'] as String,
  connected: json['connected'] as bool? ?? true,
  score: (json['score'] as num?)?.toInt() ?? 0,
  answers:
      (json['answers'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'joinedAt': instance.joinedAt,
      'connected': instance.connected,
      'score': instance.score,
      'answers': instance.answers,
    };

_SessionState _$SessionStateFromJson(Map<String, dynamic> json) =>
    _SessionState(
      sessionCode: json['sessionCode'] as String,
      quizId: json['quizId'] as String,
      hostId: json['hostId'] as String,
      status: json['status'] as String,
      mode: json['mode'] as String,
      currentQuestionIndex: (json['currentQuestionIndex'] as num).toInt(),
      quizTitle: json['quizTitle'] as String,
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SessionStateToJson(_SessionState instance) =>
    <String, dynamic>{
      'sessionCode': instance.sessionCode,
      'quizId': instance.quizId,
      'hostId': instance.hostId,
      'status': instance.status,
      'mode': instance.mode,
      'currentQuestionIndex': instance.currentQuestionIndex,
      'quizTitle': instance.quizTitle,
      'totalQuestions': instance.totalQuestions,
      'participants': instance.participants,
      'participantCount': instance.participantCount,
    };

_GameState _$GameStateFromJson(Map<String, dynamic> json) => _GameState(
  currentQuestion: json['currentQuestion'] as Map<String, dynamic>?,
  questionIndex: (json['questionIndex'] as num?)?.toInt() ?? 0,
  totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
  timeRemaining: (json['timeRemaining'] as num?)?.toInt() ?? 30,
  hasAnswered: json['hasAnswered'] as bool? ?? false,
  isCorrect: json['isCorrect'] as bool?,
  pointsEarned: (json['pointsEarned'] as num?)?.toInt(),
  correctAnswer: json['correctAnswer'],
  rankings:
      (json['rankings'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
);

Map<String, dynamic> _$GameStateToJson(_GameState instance) =>
    <String, dynamic>{
      'currentQuestion': instance.currentQuestion,
      'questionIndex': instance.questionIndex,
      'totalQuestions': instance.totalQuestions,
      'timeRemaining': instance.timeRemaining,
      'hasAnswered': instance.hasAnswered,
      'isCorrect': instance.isCorrect,
      'pointsEarned': instance.pointsEarned,
      'correctAnswer': instance.correctAnswer,
      'rankings': instance.rankings,
    };

_LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    _LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      userId: json['userId'] as String,
      score: (json['score'] as num).toInt(),
    );

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'userId': instance.userId,
      'score': instance.score,
    };

_LeaderboardState _$LeaderboardStateFromJson(Map<String, dynamic> json) =>
    _LeaderboardState(
      rankings:
          (json['rankings'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentUserEntry:
          json['currentUserEntry'] == null
              ? null
              : LeaderboardEntry.fromJson(
                json['currentUserEntry'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$LeaderboardStateToJson(_LeaderboardState instance) =>
    <String, dynamic>{
      'rankings': instance.rankings,
      'currentUserEntry': instance.currentUserEntry,
    };
