import 'package:nowly/core/models/user.dart';

class UserBadge {
  final String key;
  final String assetPath;
  final bool Function(User user) isUnlocked;

  const UserBadge({
    required this.key,
    required this.assetPath,
    required this.isUnlocked,
  });
}

abstract final class UserBadges {
  static final List<UserBadge> values = [
    // Default
    UserBadge(
      key: 'nowly_hourglass',
      assetPath: 'assets/images/badges/nowly_hourglass.jpg',
      isUnlocked: (user) => true,
    ),
    UserBadge(
      key: 'nowly_letter',
      assetPath: 'assets/images/badges/nowly_letter.jpg',
      isUnlocked: (user) => true,
    ),

    // Completed
    UserBadge(
      key: 'completed_01',
      assetPath: 'assets/images/badges/completed_01.jpg',
      isUnlocked: (user) => user.totalCompleted >= 1,
    ),
    UserBadge(
      key: 'completed_10',
      assetPath: 'assets/images/badges/completed_10.jpg',
      isUnlocked: (user) => user.totalCompleted >= 10,
    ),

    // Canceled
    UserBadge(
      key: 'canceled_10',
      assetPath: 'assets/images/badges/canceled_10.jpg',
      isUnlocked: (user) => user.totalCanceled >= 10,
    ),

    // Expired
    UserBadge(
      key: 'expired_10',
      assetPath: 'assets/images/badges/expired_10.jpg',
      isUnlocked: (user) => user.totalExpired >= 10,
    ),

    // Level
    UserBadge(
      key: 'level_0001',
      assetPath: 'assets/images/badges/level_0001.jpg',
      isUnlocked: (user) => user.highestLevel >= 1,
    ),
    UserBadge(
      key: 'level_0005',
      assetPath: 'assets/images/badges/level_0005.jpg',
      isUnlocked: (user) => user.highestLevel >= 5,
    ),
    UserBadge(
      key: 'level_0010',
      assetPath: 'assets/images/badges/level_0010.jpg',
      isUnlocked: (user) => user.highestLevel >= 10,
    ),
    UserBadge(
      key: 'level_0025',
      assetPath: 'assets/images/badges/level_0025.jpg',
      isUnlocked: (user) => user.highestLevel >= 25,
    ),
    UserBadge(
      key: 'level_0050',
      assetPath: 'assets/images/badges/level_0050.jpg',
      isUnlocked: (user) => user.highestLevel >= 50,
    ),
    UserBadge(
      key: 'level_0075',
      assetPath: 'assets/images/badges/level_0075.jpg',
      isUnlocked: (user) => user.highestLevel >= 75,
    ),
    UserBadge(
      key: 'level_0100',
      assetPath: 'assets/images/badges/level_0100.jpg',
      isUnlocked: (user) => user.highestLevel >= 100,
    ),
    UserBadge(
      key: 'level_0250',
      assetPath: 'assets/images/badges/level_0250.jpg',
      isUnlocked: (user) => user.highestLevel >= 250,
    ),
    UserBadge(
      key: 'level_0400',
      assetPath: 'assets/images/badges/level_0400.jpg',
      isUnlocked: (user) => user.highestLevel >= 400,
    ),
    UserBadge(
      key: 'level_0600',
      assetPath: 'assets/images/badges/level_0600.jpg',
      isUnlocked: (user) => user.highestLevel >= 600,
    ),
    UserBadge(
      key: 'level_0800',
      assetPath: 'assets/images/badges/level_0800.jpg',
      isUnlocked: (user) => user.highestLevel >= 800,
    ),
    UserBadge(
      key: 'level_0900',
      assetPath: 'assets/images/badges/level_0900.jpg',
      isUnlocked: (user) => user.highestLevel >= 900,
    ),
    UserBadge(
      key: 'level_0999',
      assetPath: 'assets/images/badges/level_0999.jpg',
      isUnlocked: (user) => user.highestLevel >= 999,
    ),
    UserBadge(
      key: 'level_1000',
      assetPath: 'assets/images/badges/level_1000.jpg',
      isUnlocked: (user) => user.highestLevel >= 1000,
    ),
    UserBadge(
      key: 'level_2000',
      assetPath: 'assets/images/badges/level_2000.jpg',
      isUnlocked: (user) => user.highestLevel >= 2000,
    ),
  ];
}
