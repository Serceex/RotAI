import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String userId;
  final AchievementType type;
  final String? category; // Kategori uzmanı rozetleri için
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.userId,
    required this.type,
    this.category,
    required this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'category': category,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: AchievementTypeExtension.fromString(map['type'] ?? ''),
      category: map['category'],
      unlockedAt: DateTime.parse(map['unlockedAt']),
    );
  }
}

enum AchievementType {
  firstAnalysis, // İlk Analiz
  tenAnalyses, // 10 Analiz Oluşturdu
  fiftyVotes, // 50 Oy Verdi
  categoryExpert, // Kategori Uzmanı
  communityLeader, // Topluluk Lideri
}

extension AchievementTypeExtension on AchievementType {
  static AchievementType fromString(String value) {
    switch (value) {
      case 'AchievementType.firstAnalysis':
      case 'firstAnalysis':
        return AchievementType.firstAnalysis;
      case 'AchievementType.tenAnalyses':
      case 'tenAnalyses':
        return AchievementType.tenAnalyses;
      case 'AchievementType.fiftyVotes':
      case 'fiftyVotes':
        return AchievementType.fiftyVotes;
      case 'AchievementType.categoryExpert':
      case 'categoryExpert':
        return AchievementType.categoryExpert;
      case 'AchievementType.communityLeader':
      case 'communityLeader':
        return AchievementType.communityLeader;
      default:
        return AchievementType.firstAnalysis;
    }
  }

  String get name {
    switch (this) {
      case AchievementType.firstAnalysis:
        return 'İlk Analiz';
      case AchievementType.tenAnalyses:
        return '10 Analiz Oluşturdu';
      case AchievementType.fiftyVotes:
        return '50 Oy Verdi';
      case AchievementType.categoryExpert:
        return 'Kategori Uzmanı';
      case AchievementType.communityLeader:
        return 'Topluluk Lideri';
    }
  }

  String get description {
    switch (this) {
      case AchievementType.firstAnalysis:
        return 'İlk analizinizi oluşturdunuz!';
      case AchievementType.tenAnalyses:
        return '10 analiz oluşturarak deneyim kazandınız.';
      case AchievementType.fiftyVotes:
        return '50 oy vererek topluluğa katkıda bulundunuz.';
      case AchievementType.categoryExpert:
        return 'Bu kategoride uzmanlaştınız.';
      case AchievementType.communityLeader:
        return 'Topluluk lideri oldunuz!';
    }
  }

  String get icon {
    switch (this) {
      case AchievementType.firstAnalysis:
        return '🎯';
      case AchievementType.tenAnalyses:
        return '📊';
      case AchievementType.fiftyVotes:
        return '🗳️';
      case AchievementType.categoryExpert:
        return '⭐';
      case AchievementType.communityLeader:
        return '👑';
    }
  }

  Color get color {
    switch (this) {
      case AchievementType.firstAnalysis:
        return const Color(0xFF4CAF50); // Yeşil
      case AchievementType.tenAnalyses:
        return const Color(0xFF2196F3); // Mavi
      case AchievementType.fiftyVotes:
        return const Color(0xFFFF9800); // Turuncu
      case AchievementType.categoryExpert:
        return const Color(0xFF9C27B0); // Mor
      case AchievementType.communityLeader:
        return const Color(0xFFFFD700); // Altın
    }
  }
}

