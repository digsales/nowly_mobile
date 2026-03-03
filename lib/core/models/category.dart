import 'dart:ui';

class Category {
  final String id;
  final String userId;
  final String name;
  final Color color;
  final String iconName;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.iconName,
  });

  factory Category.fromJson(String id, Map<String, dynamic> json) {
    return Category(
      id: id,
      userId: json['userId'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
      iconName: json['iconName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'color': color.toARGB32(),
      'iconName': iconName,
    };
  }

  Category copyWith({
    String? userId,
    String? name,
    Color? color,
    String? iconName,
  }) {
    return Category(
      id: id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
    );
  }
}
