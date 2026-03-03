class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final int totalPoints;
  final int totalCompleted;
  final int totalExpired;
  final int currentStreak;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    required this.totalPoints,
    required this.totalCompleted,
    required this.totalExpired,
    required this.currentStreak,
  });

  factory User.fromJson(String id, Map<String, dynamic> json) {
    return User(
      id: id,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalPoints: json['totalPoints'] as int,
      totalCompleted: json['totalCompleted'] as int,
      totalExpired: json['totalExpired'] as int,
      currentStreak: json['currentStreak'] as int,
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
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
