class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final int totalPoints;
  final int totalCompleted;
  final int totalExpired;
  final int totalCanceled;
  final int currentStreak;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    this.totalPoints = 0,
    this.totalCompleted = 0,
    this.totalExpired = 0,
    this.totalCanceled = 0,
    this.currentStreak = 0,
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
      totalCanceled: json['totalCanceled'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
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
      'totalCanceled': totalCanceled,
      'currentStreak': currentStreak,
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
    int? totalCanceled,
    int? currentStreak,
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
      totalCanceled: totalCanceled ?? this.totalCanceled,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
