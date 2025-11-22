import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/multiplayer_models.dart';

final leaderboardProvider = NotifierProvider<LeaderboardNotifier, LeaderboardState>(LeaderboardNotifier.new);

class LeaderboardNotifier extends Notifier<LeaderboardState> {
  @override
  LeaderboardState build() {
    return const LeaderboardState();
  }

  void updateLeaderboard(List<Map<String, dynamic>> rankingsData) {
    final rankings = rankingsData.map((data) => LeaderboardEntry.fromJson(data)).toList();
    
    // Sort by score descending
    rankings.sort((a, b) => b.score.compareTo(a.score));
    
    state = state.copyWith(rankings: rankings);
  }

  void updateScore(String userId, int newScore) {
    final currentRankings = List<LeaderboardEntry>.from(state.rankings);
    final index = currentRankings.indexWhere((entry) => entry.userId == userId);
    
    if (index != -1) {
      currentRankings[index] = currentRankings[index].copyWith(score: newScore);
      
      // Re-sort
      currentRankings.sort((a, b) => b.score.compareTo(a.score));
      
      // Update ranks
      final updatedRankings = currentRankings.asMap().map((i, entry) {
        return MapEntry(i, entry.copyWith(rank: i + 1));
      }).values.toList();
      
      state = state.copyWith(rankings: updatedRankings);
    }
  }
  
  void clearLeaderboard() {
    state = const LeaderboardState();
  }
}
