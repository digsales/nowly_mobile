import 'package:nowly/core/models/user.dart';

enum BadgeType { defaultBadge, completed, canceled, expired, level }

class UserBadge {
  final String key;
  final String name;
  final String description;
  final String assetPath;
  final BadgeType type;
  final int threshold;

  const UserBadge({
    required this.key,
    required this.name,
    required this.description,
    required this.assetPath,
    this.type = BadgeType.defaultBadge,
    this.threshold = 0,
  });

  bool isUnlocked(User user) => user.unlockedBadges.contains(key);

  /// Returns a value between 0.0 and 1.0 representing the user's progress.
  double progress(User user) {
    if (threshold <= 0) return 1.0;
    final current = switch (type) {
      BadgeType.defaultBadge => threshold,
      BadgeType.completed => user.totalCompleted,
      BadgeType.canceled => user.totalCanceled,
      BadgeType.expired => user.totalExpired,
      BadgeType.level => user.highestLevel,
    };
    return (current / threshold).clamp(0.0, 1.0);
  }

  /// Returns the current value for this badge's criteria.
  int currentValue(User user) {
    return switch (type) {
      BadgeType.defaultBadge => threshold,
      BadgeType.completed => user.totalCompleted,
      BadgeType.canceled => user.totalCanceled,
      BadgeType.expired => user.totalExpired,
      BadgeType.level => user.highestLevel,
    };
  }

  /// Checks if the user meets the criteria to earn this badge.
  bool shouldUnlock(User user) {
    return switch (type) {
      BadgeType.defaultBadge => true,
      BadgeType.completed => user.totalCompleted >= threshold,
      BadgeType.canceled => user.totalCanceled >= threshold,
      BadgeType.expired => user.totalExpired >= threshold,
      BadgeType.level => user.highestLevel >= threshold,
    };
  }
}

abstract final class UserBadges {
  static const List<String> defaultKeys = [
    'nowly_hourglass',
    'nowly_letter',
  ];

  /// Returns badge keys the user has earned but hasn't unlocked yet.
  static List<String> pendingUnlocks(User user) {
    return values
        .where((b) => !b.isUnlocked(user) && b.shouldUnlock(user))
        .map((b) => b.key)
        .toList();
  }

  static const List<UserBadge> values = [
    // Default
    UserBadge(
      key: 'nowly_hourglass',
      name: 'Ampulheta Nowly',
      description: 'Bem-vindo ao Nowly!',
      assetPath: 'assets/images/badges/nowly_hourglass.jpg',
    ),
    UserBadge(
      key: 'nowly_letter',
      name: 'N Nowly',
      description: 'Bem-vindo ao Nowly!',
      assetPath: 'assets/images/badges/nowly_letter.jpg',
    ),

    // Completed
    UserBadge(
      key: 'completed_01',
      name: 'Primeira Conquista',
      description: 'Complete sua primeira tarefa.',
      assetPath: 'assets/images/badges/completed_01.jpg',
      type: BadgeType.completed,
      threshold: 1,
    ),
    UserBadge(
      key: 'completed_10',
      name: 'Dedicação Total',
      description: 'Complete 10 tarefas.',
      assetPath: 'assets/images/badges/completed_10.jpg',
      type: BadgeType.completed,
      threshold: 10,
    ),

    // Canceled
    UserBadge(
      key: 'canceled_10',
      name: 'Mudança de Planos',
      description: 'Cancele 10 tarefas.',
      assetPath: 'assets/images/badges/canceled_10.jpg',
      type: BadgeType.canceled,
      threshold: 10,
    ),

    // Expired
    UserBadge(
      key: 'expired_10',
      name: 'Tempo Esgotado',
      description: 'Deixe 10 tarefas expirarem.',
      assetPath: 'assets/images/badges/expired_10.jpg',
      type: BadgeType.expired,
      threshold: 10,
    ),

    // Level
    UserBadge(
      key: 'level_0001',
      name: 'Primeiro Passo',
      description: 'Alcance o nível 1.',
      assetPath: 'assets/images/badges/level_0001.jpg',
      type: BadgeType.level,
      threshold: 1,
    ),
    UserBadge(
      key: 'level_0005',
      name: 'Aquecendo',
      description: 'Alcance o nível 5.',
      assetPath: 'assets/images/badges/level_0005.jpg',
      type: BadgeType.level,
      threshold: 5,
    ),
    UserBadge(
      key: 'level_0010',
      name: 'Em Ritmo',
      description: 'Alcance o nível 10.',
      assetPath: 'assets/images/badges/level_0010.jpg',
      type: BadgeType.level,
      threshold: 10,
    ),
    UserBadge(
      key: 'level_0025',
      name: 'Focado',
      description: 'Alcance o nível 25.',
      assetPath: 'assets/images/badges/level_0025.jpg',
      type: BadgeType.level,
      threshold: 25,
    ),
    UserBadge(
      key: 'level_0050',
      name: 'Meio Caminho',
      description: 'Alcance o nível 50.',
      assetPath: 'assets/images/badges/level_0050.jpg',
      type: BadgeType.level,
      threshold: 50,
    ),
    UserBadge(
      key: 'level_0075',
      name: 'Veterano',
      description: 'Alcance o nível 75.',
      assetPath: 'assets/images/badges/level_0075.jpg',
      type: BadgeType.level,
      threshold: 75,
    ),
    UserBadge(
      key: 'level_0100',
      name: 'Centurião',
      description: 'Alcance o nível 100.',
      assetPath: 'assets/images/badges/level_0100.jpg',
      type: BadgeType.level,
      threshold: 100,
    ),
    UserBadge(
      key: 'level_0250',
      name: 'Elite',
      description: 'Alcance o nível 250.',
      assetPath: 'assets/images/badges/level_0250.jpg',
      type: BadgeType.level,
      threshold: 250,
    ),
    UserBadge(
      key: 'level_0400',
      name: 'Mestre',
      description: 'Alcance o nível 400.',
      assetPath: 'assets/images/badges/level_0400.jpg',
      type: BadgeType.level,
      threshold: 400,
    ),
    UserBadge(
      key: 'level_0600',
      name: 'Grão-Mestre',
      description: 'Alcance o nível 600.',
      assetPath: 'assets/images/badges/level_0600.jpg',
      type: BadgeType.level,
      threshold: 600,
    ),
    UserBadge(
      key: 'level_0800',
      name: 'Lendário',
      description: 'Alcance o nível 800.',
      assetPath: 'assets/images/badges/level_0800.jpg',
      type: BadgeType.level,
      threshold: 800,
    ),
    UserBadge(
      key: 'level_0900',
      name: 'Mítico',
      description: 'Alcance o nível 900.',
      assetPath: 'assets/images/badges/level_0900.jpg',
      type: BadgeType.level,
      threshold: 900,
    ),
    UserBadge(
      key: 'level_0999',
      name: 'Quase Lá',
      description: 'Alcance o nível 999.',
      assetPath: 'assets/images/badges/level_0999.jpg',
      type: BadgeType.level,
      threshold: 999,
    ),
    UserBadge(
      key: 'level_1000',
      name: 'Milênio',
      description: 'Alcance o nível 1000.',
      assetPath: 'assets/images/badges/level_1000.jpg',
      type: BadgeType.level,
      threshold: 1000,
    ),
    UserBadge(
      key: 'level_2000',
      name: 'Transcendente',
      description: 'Alcance o nível 2000.',
      assetPath: 'assets/images/badges/level_2000.jpg',
      type: BadgeType.level,
      threshold: 2000,
    ),
  ];
}
