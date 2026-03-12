import 'package:flutter/material.dart';
import 'package:nowly/core/theme/primary_colors.dart';

class Category {
  final String id;
  final String userId;
  final String name;
  final String colorKey;
  final String iconName;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.colorKey,
    required this.iconName,
  });

  factory Category.fromJson(String id, Map<String, dynamic> json) {
    return Category(
      id: id,
      userId: json['userId'] as String,
      name: json['name'] as String,
      colorKey: json['colorKey'] as String,
      iconName: json['iconName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'colorKey': colorKey,
      'iconName': iconName,
    };
  }

  Category copyWith({
    String? userId,
    String? name,
    String? colorKey,
    String? iconName,
  }) {
    return Category(
      id: id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      colorKey: colorKey ?? this.colorKey,
      iconName: iconName ?? this.iconName,
    );
  }

  /// Resolves the display color based on theme brightness and high contrast.
  Color resolveColor({
    required Brightness brightness,
    required bool highContrast,
  }) {
    final colors = AppPrimaryColors.values.firstWhere(
      (c) => c.key == colorKey,
      orElse: () => AppPrimaryColors.purple,
    );

    if (!highContrast) return colors.primary;
    return brightness == Brightness.dark ? colors.light : colors.dark;
  }
}
