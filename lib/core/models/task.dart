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
  final DateTime endDate;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int pointsEarned;

  const Task({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.title,
    this.description,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.pointsEarned,
  });

  factory Task.fromJson(String id, Map<String, dynamic> json) {
    return Task(
      id: id,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      endDate: DateTime.parse(json['endDate'] as String),
      status: TaskStatusX.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
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
      'endDate': endDate.toIso8601String(),
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'pointsEarned': pointsEarned,
    };
  }

  bool get canDelete =>
      DateTime.now().difference(createdAt).inMinutes < 30;

  bool get canUncancel =>
      status == TaskStatus.cancelled && endDate.isAfter(DateTime.now());

  Task copyWith({
    String? userId,
    String? categoryId,
    String? title,
    String? description,
    DateTime? endDate,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    int? pointsEarned,
  }) {
    return Task(
      id: id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }
}
