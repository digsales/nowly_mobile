class LeaderboardEntry {
  final String userId;
  final int points;
  final int completedTasks;
  final int expiredTasks;

  const LeaderboardEntry({
    required this.userId,
    required this.points,
    required this.completedTasks,
    required this.expiredTasks,
  });

  factory LeaderboardEntry.fromJson(String userId, Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: userId,
      points: json['points'] as int,
      completedTasks: json['completedTasks'] as int,
      expiredTasks: json['expiredTasks'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'completedTasks': completedTasks,
      'expiredTasks': expiredTasks,
    };
  }

  LeaderboardEntry copyWith({
    int? points,
    int? completedTasks,
    int? expiredTasks,
  }) {
    return LeaderboardEntry(
      userId: userId,
      points: points ?? this.points,
      completedTasks: completedTasks ?? this.completedTasks,
      expiredTasks: expiredTasks ?? this.expiredTasks,
    );
  }
}

class MonthlyRanking {
  final String month;
  final List<LeaderboardEntry> leaderboard;

  const MonthlyRanking({
    required this.month,
    required this.leaderboard,
  });

  factory MonthlyRanking.fromJson(String month, Map<String, dynamic> json) {
    final leaderboardMap =
        json['leaderboard'] as Map<String, dynamic>? ?? {};

    final entries = leaderboardMap.entries
        .map((e) => LeaderboardEntry.fromJson(
              e.key,
              e.value as Map<String, dynamic>,
            ))
        .toList();

    return MonthlyRanking(month: month, leaderboard: entries);
  }

  Map<String, dynamic> toJson() {
    return {
      'leaderboard': {
        for (final entry in leaderboard) entry.userId: entry.toJson(),
      },
    };
  }
}
