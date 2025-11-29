class UserLevel {
  final int level;
  final String levelName;
  final String badge; // Emoji
  final int totalPoints;
  final int pointsForCurrentLevel;
  final int pointsForNextLevel;

  UserLevel({
    required this.level,
    required this.levelName,
    required this.badge,
    required this.totalPoints,
    required this.pointsForCurrentLevel,
    required this.pointsForNextLevel,
  });

  double get progressPercentage {
    if (pointsForNextLevel == pointsForCurrentLevel) return 1.0;
    final progress = (totalPoints - pointsForCurrentLevel) /
        (pointsForNextLevel - pointsForCurrentLevel);
    return progress.clamp(0.0, 1.0);
  }

  int get pointsNeededForNextLevel => pointsForNextLevel - totalPoints;
}

