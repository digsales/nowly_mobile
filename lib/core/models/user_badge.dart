import 'package:nowly/core/models/user.dart';

class UserBadge {
  final String key;
  final String name;
  final String description;
  final String assetPath;
  final bool Function(User user) isUnlocked;

  const UserBadge({
    required this.key,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.isUnlocked,
  });
}

abstract final class UserBadges {
  static final List<UserBadge> values = [
    // Default
    UserBadge(
      key: 'nowly_hourglass',
      name: 'Ampulheta Nowly',
      description: 'Bem-vindo ao Nowly!',
      assetPath: 'assets/images/badges/nowly_hourglass.jpg',
      isUnlocked: (user) => true,
    ),
    UserBadge(
      key: 'nowly_letter',
      name: 'N Nowly',
      description: 'Bem-vindo ao Nowly!',
      assetPath: 'assets/images/badges/nowly_letter.jpg',
      isUnlocked: (user) => true,
    ),

    // Completed
    UserBadge(
      key: 'completed_01',
      name: 'Primeira Conquista',
      description: 'Complete sua primeira tarefa.',
      assetPath: 'assets/images/badges/completed_01.jpg',
      isUnlocked: (user) => user.totalCompleted >= 1,
    ),
    UserBadge(
      key: 'completed_10',
      name: 'Dedicação Total',
      description: 'Complete 10 tarefas.',
      assetPath: 'assets/images/badges/completed_10.jpg',
      isUnlocked: (user) => user.totalCompleted >= 10,
    ),

    // Canceled
    UserBadge(
      key: 'canceled_10',
      name: 'Planos Mudaram',
      description: 'Cancele 10 tarefas.',
      assetPath: 'assets/images/badges/canceled_10.jpg',
      isUnlocked: (user) => user.totalCanceled >= 10,
    ),

    // Expired
    UserBadge(
      key: 'expired_10',
      name: 'Tempo Esgotado',
      description: 'Deixe 10 tarefas expirarem.',
      assetPath: 'assets/images/badges/expired_10.jpg',
      isUnlocked: (user) => user.totalExpired >= 10,
    ),

    // Level
    UserBadge(
      key: 'level_0001',
      name: 'Primeiro Passo',
      description: 'Alcance o nível 1.',
      assetPath: 'assets/images/badges/level_0001.jpg',
      isUnlocked: (user) => user.highestLevel >= 1,
    ),
    UserBadge(
      key: 'level_0005',
      name: 'Aquecendo',
      description: 'Alcance o nível 5.',
      assetPath: 'assets/images/badges/level_0005.jpg',
      isUnlocked: (user) => user.highestLevel >= 5,
    ),
    UserBadge(
      key: 'level_0010',
      name: 'Em Ritmo',
      description: 'Alcance o nível 10.',
      assetPath: 'assets/images/badges/level_0010.jpg',
      isUnlocked: (user) => user.highestLevel >= 10,
    ),
    UserBadge(
      key: 'level_0025',
      name: 'Focado',
      description: 'Alcance o nível 25.',
      assetPath: 'assets/images/badges/level_0025.jpg',
      isUnlocked: (user) => user.highestLevel >= 25,
    ),
    UserBadge(
      key: 'level_0050',
      name: 'Meio Caminho',
      description: 'Alcance o nível 50.',
      assetPath: 'assets/images/badges/level_0050.jpg',
      isUnlocked: (user) => user.highestLevel >= 50,
    ),
    UserBadge(
      key: 'level_0075',
      name: 'Veterano',
      description: 'Alcance o nível 75.',
      assetPath: 'assets/images/badges/level_0075.jpg',
      isUnlocked: (user) => user.highestLevel >= 75,
    ),
    UserBadge(
      key: 'level_0100',
      name: 'Centurião',
      description: 'Alcance o nível 100.',
      assetPath: 'assets/images/badges/level_0100.jpg',
      isUnlocked: (user) => user.highestLevel >= 100,
    ),
    UserBadge(
      key: 'level_0250',
      name: 'Elite',
      description: 'Alcance o nível 250.',
      assetPath: 'assets/images/badges/level_0250.jpg',
      isUnlocked: (user) => user.highestLevel >= 250,
    ),
    UserBadge(
      key: 'level_0400',
      name: 'Mestre',
      description: 'Alcance o nível 400.',
      assetPath: 'assets/images/badges/level_0400.jpg',
      isUnlocked: (user) => user.highestLevel >= 400,
    ),
    UserBadge(
      key: 'level_0600',
      name: 'Grão-Mestre',
      description: 'Alcance o nível 600.',
      assetPath: 'assets/images/badges/level_0600.jpg',
      isUnlocked: (user) => user.highestLevel >= 600,
    ),
    UserBadge(
      key: 'level_0800',
      name: 'Lendário',
      description: 'Alcance o nível 800.',
      assetPath: 'assets/images/badges/level_0800.jpg',
      isUnlocked: (user) => user.highestLevel >= 800,
    ),
    UserBadge(
      key: 'level_0900',
      name: 'Mítico',
      description: 'Alcance o nível 900.',
      assetPath: 'assets/images/badges/level_0900.jpg',
      isUnlocked: (user) => user.highestLevel >= 900,
    ),
    UserBadge(
      key: 'level_0999',
      name: 'Quase Lá',
      description: 'Alcance o nível 999.',
      assetPath: 'assets/images/badges/level_0999.jpg',
      isUnlocked: (user) => user.highestLevel >= 999,
    ),
    UserBadge(
      key: 'level_1000',
      name: 'Milênio',
      description: 'Alcance o nível 1000.',
      assetPath: 'assets/images/badges/level_1000.jpg',
      isUnlocked: (user) => user.highestLevel >= 1000,
    ),
    UserBadge(
      key: 'level_2000',
      name: 'Transcendente',
      description: 'Alcance o nível 2000.',
      assetPath: 'assets/images/badges/level_2000.jpg',
      isUnlocked: (user) => user.highestLevel >= 2000,
    ),
  ];
}
