import '../models/achievement.dart';

class AchievementsConfig {
  static List<Achievement> getAllAchievements() {
    return [
      // Decision Achievements
      Achievement(
        id: 'first_decision',
        title: 'İlk Karar',
        description: 'İlk karar analizi oluştur',
        type: AchievementType.decision,
        icon: '🎯',
        points: 10,
        requiredCount: 1,
      ),
      Achievement(
        id: 'decision_master',
        title: 'Karar Ustası',
        description: '10 karar analizi oluştur',
        type: AchievementType.decision,
        icon: '👑',
        points: 50,
        requiredCount: 10,
      ),
      
      // Vote Achievements
      Achievement(
        id: 'first_vote',
        title: 'İlk Oy',
        description: 'İlk oyunu kullan',
        type: AchievementType.vote,
        icon: '🗳️',
        points: 5,
        requiredCount: 1,
      ),
      Achievement(
        id: 'active_voter',
        title: 'Aktif Oyuncu',
        description: '50 oy kullan',
        type: AchievementType.vote,
        icon: '📊',
        points: 100,
        requiredCount: 50,
      ),
      
      // Escape Room Achievements
      Achievement(
        id: 'first_room',
        title: 'İlk Oda',
        description: 'İlk escape room\'u tamamla',
        type: AchievementType.escapeRoom,
        icon: '🚪',
        points: 20,
        requiredCount: 1,
      ),
      Achievement(
        id: 'fast_decision',
        title: 'Hızlı Karar',
        description: 'Bir odayı süre dolmadan tamamla',
        type: AchievementType.escapeRoom,
        icon: '⚡',
        points: 30,
        requiredCount: 1,
      ),
      Achievement(
        id: 'no_hints',
        title: 'İpucusuz',
        description: 'İpucu kullanmadan bir odayı tamamla',
        type: AchievementType.escapeRoom,
        icon: '🧠',
        points: 50,
        requiredCount: 1,
      ),
      Achievement(
        id: 'expert_escape',
        title: 'Uzman Kaçışçı',
        description: '10 escape room tamamla',
        type: AchievementType.escapeRoom,
        icon: '🏆',
        points: 200,
        requiredCount: 10,
      ),
      Achievement(
        id: 'escape_master',
        title: 'Escape Room Ustası',
        description: '50 escape room tamamla',
        type: AchievementType.escapeRoom,
        icon: '👑',
        points: 500,
        requiredCount: 50,
      ),
      
      // Story Achievements
      Achievement(
        id: 'story_starter',
        title: 'Hikaye Başlatıcı',
        description: 'İlk hikayeyi tamamla',
        type: AchievementType.story,
        icon: '📖',
        points: 50,
        requiredCount: 1,
      ),
      
      // Multiplayer Achievements
      Achievement(
        id: 'team_player',
        title: 'Takım Oyuncusu',
        description: 'İlk multiplayer odaya katıl',
        type: AchievementType.multiplayer,
        icon: '👥',
        points: 30,
        requiredCount: 1,
      ),
    ];
  }

  static Achievement? getById(String id) {
    try {
      return getAllAchievements().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Achievement> getByType(AchievementType type) {
    return getAllAchievements().where((a) => a.type == type).toList();
  }
}

