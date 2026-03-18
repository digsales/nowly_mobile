class Subtask {
  final String id;
  final String title;
  final bool isDone;
  final int order;

  const Subtask({
    required this.id,
    required this.title,
    this.isDone = false,
    this.order = 0,
  });

  factory Subtask.fromJson(String id, Map<String, dynamic> json) {
    return Subtask(
      id: id,
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
      'order': order,
    };
  }

  Subtask copyWith({String? title, bool? isDone, int? order}) {
    return Subtask(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      order: order ?? this.order,
    );
  }
}
