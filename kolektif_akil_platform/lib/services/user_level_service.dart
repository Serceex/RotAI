import '../models/user_level.dart';
import '../services/achievement_service.dart';

class UserLevelService {
  final AchievementService _achievementService = AchievementService();

  // Kullanıcı seviyesini hesapla
  Future<UserLevel> getUserLevel(String userId) async {
    final totalPoints =
        await _achievementService.getUserTotalPoints(userId);

    // Seviye hesaplama (her seviye için gerekli puan artışı)
    int level = 1;
    int pointsForCurrentLevel = 0;
    int pointsForNextLevel = 100;

    while (totalPoints >= pointsForNextLevel) {
      level++;
      pointsForCurrentLevel = pointsForNextLevel;
      pointsForNextLevel = _getPointsForLevel(level);
    }

    return UserLevel(
      level: level,
      levelName: _getLevelName(level),
      badge: _getLevelBadge(level),
      totalPoints: totalPoints,
      pointsForCurrentLevel: pointsForCurrentLevel,
      pointsForNextLevel: pointsForNextLevel,
    );
  }

  int _getPointsForLevel(int level) {
    // Her seviye için gerekli puan: 100, 250, 500, 1000, 2000, 5000, 10000...
    if (level == 1) return 100;
    if (level == 2) return 250;
    if (level == 3) return 500;
    if (level == 4) return 1000;
    if (level == 5) return 2000;
    if (level == 6) return 5000;
    if (level == 7) return 10000;
    if (level == 8) return 25000;
    if (level == 9) return 50000;
    // Level 10 ve üzeri için
    return 100000 * (level - 9);
  }

  String _getLevelName(int level) {
    if (level <= 5) {
      return ['Yeni Başlayan', 'Acemi', 'Orta Seviye', 'Deneyimli', 'Uzman'][
          level - 1];
    } else if (level <= 10) {
      return ['Usta', 'Profesyonel', 'Elit', 'Efsane', 'Efsanevi'][
          level - 6];
    } else {
      return 'Efsanevi Seviye $level';
    }
  }

  String _getLevelBadge(int level) {
    if (level <= 3) return '🌱';
    if (level <= 5) return '🌿';
    if (level <= 7) return '🌳';
    if (level <= 10) return '🏆';
    return '👑';
  }
}

