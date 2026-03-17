class Subtask {
  final String id;
  final String title;
  final bool isDone;

  const Subtask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  factory Subtask.fromJson(String id, Map<String, dynamic> json) {
    return Subtask(
      id: id,
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }

  Subtask copyWith({String? title, bool? isDone}) {
    return Subtask(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
