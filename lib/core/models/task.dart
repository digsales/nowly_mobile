enum TaskStatus { pending, completed, expired, cancelled }

extension TaskStatusX on TaskStatus {
  static TaskStatus fromJson(String value) {
    return switch (value) {
      'completed' => TaskStatus.completed,
      'expired' => TaskStatus.expired,
      'cancelled' => TaskStatus.cancelled,
      _ => TaskStatus.pending,
    };
  }

  String toJson() {
    return switch (this) {
      TaskStatus.pending => 'pending',
      TaskStatus.completed => 'completed',
      TaskStatus.expired => 'expired',
      TaskStatus.cancelled => 'cancelled',
    };
  }
}

class Task {
  final String id;
  final String userId;
  final String? categoryId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? expiredAt;
  final int pointsEarned;

  const Task({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.expiredAt,
    required this.pointsEarned,
  });

  factory Task.fromJson(String id, Map<String, dynamic> json) {
    return Task(
      id: id,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: TaskStatusX.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      expiredAt: json['expiredAt'] != null
          ? DateTime.parse(json['expiredAt'] as String)
          : null,
      pointsEarned: json['pointsEarned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiredAt': expiredAt?.toIso8601String(),
      'pointsEarned': pointsEarned,
    };
  }

  Task copyWith({
    String? userId,
    String? categoryId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? expiredAt,
    int? pointsEarned,
  }) {
    return Task(
      id: id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      expiredAt: expiredAt ?? this.expiredAt,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }
}
