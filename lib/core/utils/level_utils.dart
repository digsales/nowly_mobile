import 'dart:math';

/// Total points required to reach [level].
///
/// Level 1 needs 10 pts, level 2 needs 30 pts (10+20), level 3 needs 60 pts (10+20+30), etc.
int pointsForLevel(int level) => 5 * level * (level + 1);

/// Current level for a user with [points] total points.
int calculateLevel(int points) =>
    ((-1 + sqrt(1 + 8 * (points / 10))) / 2).floor();

/// Progress within the current level, from 0.0 to 1.0.
double levelProgress(int points) {
  final level = calculateLevel(points);
  final start = pointsForLevel(level);
  final needed = 10 * (level + 1); // points needed for this level gap
  return (points - start) / needed;
}

/// Points still needed to reach the next level.
int pointsToNextLevel(int points) {
  final level = calculateLevel(points);
  return pointsForLevel(level + 1) - points;
}
