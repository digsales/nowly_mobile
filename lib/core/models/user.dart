class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final int totalPoints;
  final int totalCompleted;
  final int totalExpired;
  final int totalCancelled;
  final int currentStreak;
  final DateTime? lastStreakDate;
  final int highestLevel;
  final List<String> unlockedBadges;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    this.totalPoints = 0,
    this.totalCompleted = 0,
    this.totalExpired = 0,
    this.totalCancelled = 0,
    this.currentStreak = 0,
    this.lastStreakDate,
    this.highestLevel = 0,
    this.unlockedBadges = const [],
  });

  factory User.fromJson(String id, Map<String, dynamic> json) {
    return User(
      id: id,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalPoints: json['totalPoints'] as int? ?? 0,
      totalCompleted: json['totalCompleted'] as int? ?? 0,
      totalExpired: json['totalExpired'] as int? ?? 0,
      totalCancelled: json['totalCancelled'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastStreakDate: json['lastStreakDate'] != null
          ? DateTime.parse(json['lastStreakDate'] as String)
          : null,
      highestLevel: json['highestLevel'] as int? ?? 0,
      unlockedBadges: (json['unlockedBadges'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'totalPoints': totalPoints,
      'totalCompleted': totalCompleted,
      'totalExpired': totalExpired,
      'totalCancelled': totalCancelled,
      'currentStreak': currentStreak,
      'lastStreakDate': lastStreakDate?.toIso8601String(),
      'highestLevel': highestLevel,
      'unlockedBadges': unlockedBadges,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    int? totalPoints,
    int? totalCompleted,
    int? totalExpired,
    int? totalCancelled,
    int? currentStreak,
    DateTime? lastStreakDate,
    int? highestLevel,
    List<String>? unlockedBadges,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      totalPoints: totalPoints ?? this.totalPoints,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalExpired: totalExpired ?? this.totalExpired,
      totalCancelled: totalCancelled ?? this.totalCancelled,
      currentStreak: currentStreak ?? this.currentStreak,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      highestLevel: highestLevel ?? this.highestLevel,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
    );
  }
}
