import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement.dart';
import '../utils/achievements_config.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcının başarılarını getir
  Future<Map<String, bool>> getUserAchievements(String userId) async {
    final doc = await _firestore
        .collection('user_achievements')
        .doc(userId)
        .get();

    if (doc.exists) {
      return Map<String, bool>.from(doc.data() ?? {});
    }
    return {};
  }

  // Başarıyı kontrol et ve kilitle
  Future<void> checkAndUnlockAchievement(
      String userId, AchievementType type, int count) async {
    final achievements = AchievementsConfig.getByType(type);

    for (final achievement in achievements) {
      if (count >= achievement.requiredCount) {
        await unlockAchievement(userId, achievement.id);
      }
    }
  }

  // Başarıyı kilitle
  Future<void> unlockAchievement(String userId, String achievementId) async {
    final userAchievementsRef =
        _firestore.collection('user_achievements').doc(userId);

    await userAchievementsRef.set({
      achievementId: true,
    }, SetOptions(merge: true));

    // Başarı geçmişine ekle
    await _firestore.collection('achievement_history').add({
      'userId': userId,
      'achievementId': achievementId,
      'unlockedAt': DateTime.now().toIso8601String(),
    });
  }

  // Kullanıcının toplam puanını hesapla
  Future<int> getUserTotalPoints(String userId) async {
    final achievements = await getUserAchievements(userId);
    final allAchievements = AchievementsConfig.getAllAchievements();

    int totalPoints = 0;
    for (final achievement in allAchievements) {
      if (achievements[achievement.id] == true) {
        totalPoints += achievement.points;
      }
    }

    return totalPoints;
  }

  // Escape Room başarılarını kontrol et
  Future<void> checkEscapeRoomAchievements(
      String userId, int completedRooms, bool usedHints, bool timeExpired) async {
    await checkAndUnlockAchievement(
        userId, AchievementType.escapeRoom, completedRooms);

    if (completedRooms == 1) {
      await unlockAchievement(userId, 'first_room');
    }

    if (!usedHints && completedRooms >= 1) {
      await unlockAchievement(userId, 'no_hints');
    }

    if (!timeExpired && completedRooms >= 1) {
      await unlockAchievement(userId, 'fast_decision');
    }
  }
}

