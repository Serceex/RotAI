import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement.dart';
import '../services/firebase_service.dart';

class AchievementProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Achievement> _achievements = [];
  bool _isLoading = false;

  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;

  Future<void> loadUserAchievements(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _achievements = await _firebaseService.getUserAchievements(userId);
    } catch (e) {
      debugPrint('Rozet yükleme hatası: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Achievement>> getUserAchievementsStream(String userId) {
    return _firebaseService.getUserAchievementsStream(userId);
  }

  /// Analiz oluşturma sonrası rozet kontrolü
  Future<List<Achievement>> checkAnalysisAchievements(String userId) async {
    final unlockedAchievements = <Achievement>[];

    try {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(userId);

      // Kullanıcının analiz sayısını kontrol et
      final decisionsSnapshot = await firestore
          .collection('decisions')
          .where('userRef', isEqualTo: userRef)
          .where('decisionTree', isNotEqualTo: null)
          .get();

      final analysisCount = decisionsSnapshot.docs.length;

      // İlk Analiz rozeti
      if (analysisCount >= 1) {
        final hasAchievement = await _firebaseService.hasAchievement(
          userId,
          AchievementType.firstAnalysis,
        );
        if (!hasAchievement) {
          await _firebaseService.createAchievement(
            userId,
            AchievementType.firstAnalysis,
          );
          final newAchievement = Achievement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            type: AchievementType.firstAnalysis,
            unlockedAt: DateTime.now(),
          );
          unlockedAchievements.add(newAchievement);
        }
      }

      // 10 Analiz rozeti
      if (analysisCount >= 10) {
        final hasAchievement = await _firebaseService.hasAchievement(
          userId,
          AchievementType.tenAnalyses,
        );
        if (!hasAchievement) {
          await _firebaseService.createAchievement(
            userId,
            AchievementType.tenAnalyses,
          );
          final newAchievement = Achievement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            type: AchievementType.tenAnalyses,
            unlockedAt: DateTime.now(),
          );
          unlockedAchievements.add(newAchievement);
        }
      }

      // Kategori uzmanı rozetleri kontrol et
      final categoryCounts = <String, int>{};
      for (var doc in decisionsSnapshot.docs) {
        final category = doc.data()['category'] as String? ?? 'Genel';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      // Her kategoride 5 veya daha fazla analiz varsa kategori uzmanı rozeti
      for (var entry in categoryCounts.entries) {
        if (entry.value >= 5) {
          final hasAchievement = await _firebaseService.hasAchievement(
            userId,
            AchievementType.categoryExpert,
            category: entry.key,
          );
          if (!hasAchievement) {
            await _firebaseService.createAchievement(
              userId,
              AchievementType.categoryExpert,
              category: entry.key,
            );
            final newAchievement = Achievement(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: userId,
              type: AchievementType.categoryExpert,
              category: entry.key,
              unlockedAt: DateTime.now(),
            );
            unlockedAchievements.add(newAchievement);
          }
        }
      }

      // Topluluk lideri rozeti kontrol et
      // (10+ analiz oluşturmuş ve 5+ analizi oylamaya sunulmuş)
      final submittedToVote = decisionsSnapshot.docs
          .where((doc) => doc.data()['isSubmittedToVote'] == true)
          .length;

      if (analysisCount >= 10 && submittedToVote >= 5) {
        final hasAchievement = await _firebaseService.hasAchievement(
          userId,
          AchievementType.communityLeader,
        );
        if (!hasAchievement) {
          await _firebaseService.createAchievement(
            userId,
            AchievementType.communityLeader,
          );
          final newAchievement = Achievement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            type: AchievementType.communityLeader,
            unlockedAt: DateTime.now(),
          );
          unlockedAchievements.add(newAchievement);
        }
      }
    } catch (e) {
      debugPrint('Rozet kontrolü hatası: $e');
    }

    if (unlockedAchievements.isNotEmpty) {
      await loadUserAchievements(userId);
    }

    return unlockedAchievements;
  }

  /// Oy verme sonrası rozet kontrolü
  Future<List<Achievement>> checkVoteAchievements(String userId) async {
    final unlockedAchievements = <Achievement>[];

    try {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(userId);

      // Kullanıcının oy sayısını kontrol et
      final votesSnapshot = await firestore
          .collection('votes')
          .where('userRef', isEqualTo: userRef)
          .get();

      final voteCount = votesSnapshot.docs.length;

      // 50 Oy rozeti
      if (voteCount >= 50) {
        final hasAchievement = await _firebaseService.hasAchievement(
          userId,
          AchievementType.fiftyVotes,
        );
        if (!hasAchievement) {
          await _firebaseService.createAchievement(
            userId,
            AchievementType.fiftyVotes,
          );
          final newAchievement = Achievement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            type: AchievementType.fiftyVotes,
            unlockedAt: DateTime.now(),
          );
          unlockedAchievements.add(newAchievement);
        }
      }
    } catch (e) {
      debugPrint('Rozet kontrolü hatası: $e');
    }

    if (unlockedAchievements.isNotEmpty) {
      await loadUserAchievements(userId);
    }

    return unlockedAchievements;
  }
}

