import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

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

  static const iconMap = <String, IconData>{
    // work
    'briefcase_outline': Ionicons.briefcase_outline,
    'clipboard_outline': Ionicons.clipboard_outline,

    // study
    'book_outline': Ionicons.book_outline,
    'school_outline': Ionicons.school_outline,

    // healthy
    'heart_outline': Ionicons.heart_outline,
    'fitness_outline': Ionicons.fitness_outline,

    // house
    'home_outline': Ionicons.home_outline,
    'bed_outline': Ionicons.bed_outline,

    // social
    'person_outline': Ionicons.person_outline,
    'people_outline': Ionicons.people_outline,

    // shop
    'cart_outline': Ionicons.cart_outline,
    'pricetag_outline': Ionicons.pricetag_outline,

    // financial
    'cash_outline': Ionicons.cash_outline,
    'wallet_outline': Ionicons.wallet_outline,

    // management
    'calendar_outline': Ionicons.calendar_outline,
    'time_outline': Ionicons.time_outline,

    // communication
    'mail_outline': Ionicons.mail_outline,
    'chatbubble_outline': Ionicons.chatbubble_outline,

    // technology
    'laptop_outline': Ionicons.laptop_outline,
    'settings_outline': Ionicons.settings_outline,

    // transport / travel
    'car_outline': Ionicons.car_outline,
    'airplane_outline': Ionicons.airplane_outline,

    // leisure
    'game_controller_outline': Ionicons.game_controller_outline,
    'musical_notes_outline': Ionicons.musical_notes_outline,
  };

  /// Resolves the icon from [iconName].
  IconData get icon => iconMap[iconName] ?? Ionicons.ellipse_outline;
}
