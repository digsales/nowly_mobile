import 'package:nowly/core/models/user.dart';
import 'package:nowly/l10n/app_localizations.dart';

enum BadgeType { defaultBadge, completed, canceled, expired, level }

typedef _L10nGetter = String Function(AppLocalizations l10n);

class UserBadge {
  final String key;
  final String assetPath;
  final BadgeType type;
  final int threshold;

  const UserBadge({
    required this.key,
    required this.assetPath,
    this.type = BadgeType.defaultBadge,
    this.threshold = 0,
  });

  String name(AppLocalizations l10n) => _names[key]!(l10n);
  String description(AppLocalizations l10n) => _descs[key]!(l10n);

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

  static final Map<String, _L10nGetter> _names = {
    'nowly_hourglass': (l10n) => l10n.badgeNowlyHourglassName,
    'nowly_letter': (l10n) => l10n.badgeNowlyLetterName,
    'completed_01': (l10n) => l10n.badgeCompleted01Name,
    'completed_10': (l10n) => l10n.badgeCompleted10Name,
    'canceled_10': (l10n) => l10n.badgeCanceled10Name,
    'expired_10': (l10n) => l10n.badgeExpired10Name,
    'level_0001': (l10n) => l10n.badgeLevel0001Name,
    'level_0005': (l10n) => l10n.badgeLevel0005Name,
    'level_0010': (l10n) => l10n.badgeLevel0010Name,
    'level_0025': (l10n) => l10n.badgeLevel0025Name,
    'level_0050': (l10n) => l10n.badgeLevel0050Name,
    'level_0075': (l10n) => l10n.badgeLevel0075Name,
    'level_0100': (l10n) => l10n.badgeLevel0100Name,
    'level_0250': (l10n) => l10n.badgeLevel0250Name,
    'level_0400': (l10n) => l10n.badgeLevel0400Name,
    'level_0600': (l10n) => l10n.badgeLevel0600Name,
    'level_0800': (l10n) => l10n.badgeLevel0800Name,
    'level_0900': (l10n) => l10n.badgeLevel0900Name,
    'level_0999': (l10n) => l10n.badgeLevel0999Name,
    'level_1000': (l10n) => l10n.badgeLevel1000Name,
    'level_2000': (l10n) => l10n.badgeLevel2000Name,
  };

  static final Map<String, _L10nGetter> _descs = {
    'nowly_hourglass': (l10n) => l10n.badgeNowlyHourglassDesc,
    'nowly_letter': (l10n) => l10n.badgeNowlyLetterDesc,
    'completed_01': (l10n) => l10n.badgeCompleted01Desc,
    'completed_10': (l10n) => l10n.badgeCompleted10Desc,
    'canceled_10': (l10n) => l10n.badgeCanceled10Desc,
    'expired_10': (l10n) => l10n.badgeExpired10Desc,
    'level_0001': (l10n) => l10n.badgeLevel0001Desc,
    'level_0005': (l10n) => l10n.badgeLevel0005Desc,
    'level_0010': (l10n) => l10n.badgeLevel0010Desc,
    'level_0025': (l10n) => l10n.badgeLevel0025Desc,
    'level_0050': (l10n) => l10n.badgeLevel0050Desc,
    'level_0075': (l10n) => l10n.badgeLevel0075Desc,
    'level_0100': (l10n) => l10n.badgeLevel0100Desc,
    'level_0250': (l10n) => l10n.badgeLevel0250Desc,
    'level_0400': (l10n) => l10n.badgeLevel0400Desc,
    'level_0600': (l10n) => l10n.badgeLevel0600Desc,
    'level_0800': (l10n) => l10n.badgeLevel0800Desc,
    'level_0900': (l10n) => l10n.badgeLevel0900Desc,
    'level_0999': (l10n) => l10n.badgeLevel0999Desc,
    'level_1000': (l10n) => l10n.badgeLevel1000Desc,
    'level_2000': (l10n) => l10n.badgeLevel2000Desc,
  };
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
      assetPath: 'assets/images/badges/nowly_hourglass.jpg',
    ),
    UserBadge(
      key: 'nowly_letter',
      assetPath: 'assets/images/badges/nowly_letter.jpg',
    ),

    // Completed
    UserBadge(
      key: 'completed_01',
      assetPath: 'assets/images/badges/completed_01.jpg',
      type: BadgeType.completed,
      threshold: 1,
    ),
    UserBadge(
      key: 'completed_10',
      assetPath: 'assets/images/badges/completed_10.jpg',
      type: BadgeType.completed,
      threshold: 10,
    ),

    // Canceled
    UserBadge(
      key: 'canceled_10',
      assetPath: 'assets/images/badges/canceled_10.jpg',
      type: BadgeType.canceled,
      threshold: 10,
    ),

    // Expired
    UserBadge(
      key: 'expired_10',
      assetPath: 'assets/images/badges/expired_10.jpg',
      type: BadgeType.expired,
      threshold: 10,
    ),

    // Level
    UserBadge(
      key: 'level_0001',
      assetPath: 'assets/images/badges/level_0001.jpg',
      type: BadgeType.level,
      threshold: 1,
    ),
    UserBadge(
      key: 'level_0005',
      assetPath: 'assets/images/badges/level_0005.jpg',
      type: BadgeType.level,
      threshold: 5,
    ),
    UserBadge(
      key: 'level_0010',
      assetPath: 'assets/images/badges/level_0010.jpg',
      type: BadgeType.level,
      threshold: 10,
    ),
    UserBadge(
      key: 'level_0025',
      assetPath: 'assets/images/badges/level_0025.jpg',
      type: BadgeType.level,
      threshold: 25,
    ),
    UserBadge(
      key: 'level_0050',
      assetPath: 'assets/images/badges/level_0050.jpg',
      type: BadgeType.level,
      threshold: 50,
    ),
    UserBadge(
      key: 'level_0075',
      assetPath: 'assets/images/badges/level_0075.jpg',
      type: BadgeType.level,
      threshold: 75,
    ),
    UserBadge(
      key: 'level_0100',
      assetPath: 'assets/images/badges/level_0100.jpg',
      type: BadgeType.level,
      threshold: 100,
    ),
    UserBadge(
      key: 'level_0250',
      assetPath: 'assets/images/badges/level_0250.jpg',
      type: BadgeType.level,
      threshold: 250,
    ),
    UserBadge(
      key: 'level_0400',
      assetPath: 'assets/images/badges/level_0400.jpg',
      type: BadgeType.level,
      threshold: 400,
    ),
    UserBadge(
      key: 'level_0600',
      assetPath: 'assets/images/badges/level_0600.jpg',
      type: BadgeType.level,
      threshold: 600,
    ),
    UserBadge(
      key: 'level_0800',
      assetPath: 'assets/images/badges/level_0800.jpg',
      type: BadgeType.level,
      threshold: 800,
    ),
    UserBadge(
      key: 'level_0900',
      assetPath: 'assets/images/badges/level_0900.jpg',
      type: BadgeType.level,
      threshold: 900,
    ),
    UserBadge(
      key: 'level_0999',
      assetPath: 'assets/images/badges/level_0999.jpg',
      type: BadgeType.level,
      threshold: 999,
    ),
    UserBadge(
      key: 'level_1000',
      assetPath: 'assets/images/badges/level_1000.jpg',
      type: BadgeType.level,
      threshold: 1000,
    ),
    UserBadge(
      key: 'level_2000',
      assetPath: 'assets/images/badges/level_2000.jpg',
      type: BadgeType.level,
      threshold: 2000,
    ),
  ];
}
