enum AchievementType {
  decision,
  vote,
  analysis,
  escapeRoom,
  story,
  multiplayer,
  expert,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final String icon; // Emoji veya icon name
  final int points;
  final int requiredCount; // Kaç kez yapılması gerekiyor
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.points,
    required this.requiredCount,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'icon': icon,
      'points': points,
      'requiredCount': requiredCount,
      'isUnlocked': isUnlocked,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AchievementType.decision,
      ),
      icon: map['icon'] ?? '🏆',
      points: map['points'] ?? 0,
      requiredCount: map['requiredCount'] ?? 1,
      isUnlocked: map['isUnlocked'] ?? false,
    );
  }
}

