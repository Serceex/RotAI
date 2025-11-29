import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/decision.dart';
import '../models/vote.dart';
import '../models/location_status.dart';
import '../models/virtual_plant.dart';
import '../models/user_model.dart';
import '../models/achievement.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Decision Operations
  Future<String> createDecision(Decision decision) async {
    // Önce aynı question ve userRef ile decision var mı kontrol et
    final existingQuery = await _firestore
        .collection('decisions')
        .where('question', isEqualTo: decision.question)
        .where('userRef', isEqualTo: decision.userRef)
        .limit(1)
        .get();
    
    if (existingQuery.docs.isNotEmpty) {
      // Mevcut decision'ı güncelle (duplicate önleme)
      final existingDoc = existingQuery.docs.first;
      // Sadece isSubmittedToVote ve updatedAt güncelle, diğer alanları koru
      final updates = {
        'isSubmittedToVote': decision.isSubmittedToVote,
        'updatedAt': decision.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };
      await existingDoc.reference.update(updates);
      return existingDoc.id;
    }
    
    // Eğer decision'ın ID'si boş değilse ve Firestore'da varsa, güncelle
    if (decision.id.isNotEmpty) {
      // ID'nin timestamp olup olmadığını kontrol et (timestamp ise ignore et)
      final isTimestamp = RegExp(r'^\d+$').hasMatch(decision.id) && decision.id.length >= 10;
      if (!isTimestamp) {
        final existingDoc = await _firestore.collection('decisions').doc(decision.id).get();
        if (existingDoc.exists) {
          // Mevcut decision'ı güncelle
          await existingDoc.reference.update(decision.toMap());
          return decision.id;
        }
      }
    }
    
    // Yeni decision oluştur
    final docRef = await _firestore.collection('decisions').add(decision.toMap());
    return docRef.id;
  }

  Future<Decision?> getDecision(String decisionId) async {
    final doc = await _firestore.collection('decisions').doc(decisionId).get();
    if (doc.exists) {
      return Decision.fromMap({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  Stream<Decision?> getDecisionStream(String decisionId) {
    return _firestore
        .collection('decisions')
        .doc(decisionId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Decision.fromMap({...snapshot.data()!, 'id': snapshot.id});
      }
      return null;
    });
  }

  Stream<List<Decision>> getDecisions() {
    return _firestore
        .collection('decisions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Decision.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<Decision>> getDecisionsSubmittedToVote() {
    return _firestore
        .collection('decisions')
        .where('isSubmittedToVote', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Decision.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> deleteDecision(String decisionId) async {
    if (decisionId.isEmpty) {
      throw Exception('Decision ID boş olamaz');
    }
    
    final decisionRef = _firestore.collection('decisions').doc(decisionId);
    
    // Decision'ın var olup olmadığını kontrol et
    final decisionDoc = await decisionRef.get();
    if (!decisionDoc.exists) {
      throw Exception('Analiz bulunamadı');
    }
    
    // Önce bu decision'a ait tüm oyları sil
    final votes = await _firestore
        .collection('votes')
        .where('decisionRef', isEqualTo: decisionRef)
        .get();
    
    // Bu decision'a ait location status'ları da al
    final locationStatuses = await _firestore
        .collection('locationStatuses')
        .where('decisionRef', isEqualTo: decisionRef)
        .get();
    
    // Tüm feedbacks'leri topla
    final allFeedbacks = <DocumentReference>[];
    for (var locationDoc in locationStatuses.docs) {
      final feedbacks = await locationDoc.reference.collection('feedbacks').get();
      allFeedbacks.addAll(feedbacks.docs.map((doc) => doc.reference));
    }
    
    // Firestore batch limiti 500 işlem, eğer daha fazla varsa birden fazla batch kullan
    final allDeletes = <DocumentReference>[
      ...votes.docs.map((doc) => doc.reference),
      ...locationStatuses.docs.map((doc) => doc.reference),
      ...allFeedbacks,
      decisionRef,
    ];
    
    // Batch'leri 500'lük gruplara böl
    const batchLimit = 500;
    for (int i = 0; i < allDeletes.length; i += batchLimit) {
      final batch = _firestore.batch();
      final batchDeletes = allDeletes.skip(i).take(batchLimit);
      
      for (var ref in batchDeletes) {
        batch.delete(ref);
      }
      
      await batch.commit();
    }
  }

  Future<void> updateDecision(String decisionId, Map<String, dynamic> updates) async {
    await _firestore.collection('decisions').doc(decisionId).update(updates);
  }

  /// Tüm kararların kategorilerini günceller - null veya geçersiz kategorileri "Genel" yapar
  Future<int> updateAllDecisionCategories() async {
    final validCategories = [
      'Genel',
      'Kariyer',
      'Eğitim',
      'Finans',
      'İlişkiler',
      'Sağlık',
      'Teknoloji',
      'Seyahat',
      'Diğer',
      // İngilizce kategoriler
      'General',
      'Career',
      'Education',
      'Finance',
      'Relationships',
      'Health',
      'Technology',
      'Travel',
      'Other',
      'Lifestyle',
    ];

    final decisionsSnapshot = await _firestore.collection('decisions').get();
    int updatedCount = 0;
    WriteBatch? batch;
    int batchCount = 0;
    const batchLimit = 500;

    for (var doc in decisionsSnapshot.docs) {
      final data = doc.data();
      final currentCategory = data['category'] as String?;
      
      // Kategori null, boş veya geçersizse "Genel" yap
      bool needsUpdate = false;
      String? newCategory = 'Genel';

      if (currentCategory == null || currentCategory.isEmpty) {
        needsUpdate = true;
      } else {
        // Kategori geçerli mi kontrol et (case-insensitive)
        final categoryLower = currentCategory.toLowerCase().trim();
        final isValid = validCategories.any((cat) => cat.toLowerCase() == categoryLower);
        
        if (!isValid) {
          needsUpdate = true;
        } else {
          // İngilizce kategorileri Türkçe'ye çevir
          final categoryMap = {
            'general': 'Genel',
            'career': 'Kariyer',
            'education': 'Eğitim',
            'finance': 'Finans',
            'relationships': 'İlişkiler',
            'health': 'Sağlık',
            'technology': 'Teknoloji',
            'travel': 'Seyahat',
            'other': 'Diğer',
            'lifestyle': 'Yaşam Tarzı',
          };
          
          if (categoryMap.containsKey(categoryLower)) {
            newCategory = categoryMap[categoryLower];
            if (currentCategory != newCategory) {
              needsUpdate = true;
            }
          }
        }
      }

      if (needsUpdate) {
        // İlk batch'i oluştur veya yeni batch oluştur
        if (batch == null || batchCount >= batchLimit) {
          if (batch != null && batchCount > 0) {
            await batch.commit();
          }
          batch = _firestore.batch();
          batchCount = 0;
        }
        
        batch.update(doc.reference, {'category': newCategory});
        batchCount++;
        updatedCount++;
      }
    }

    // Kalan batch'i commit et
    if (batch != null && batchCount > 0) {
      await batch.commit();
    }

    return updatedCount;
  }

  // Vote Operations
  Future<void> createVote(Vote vote) async {
    await _firestore.collection('votes').doc(vote.id).set(vote.toMap());
  }

  Future<bool> hasUserVoted(String decisionId, String userId) async {
    final decisionRef = _firestore.collection('decisions').doc(decisionId);
    final userRef = _firestore.collection('users').doc(userId);
    final query = await _firestore
        .collection('votes')
        .where('decisionRef', isEqualTo: decisionRef)
        .where('userRef', isEqualTo: userRef)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Stream<List<Vote>> getVotesForDecision(String decisionId) {
    final decisionRef = _firestore.collection('decisions').doc(decisionId);
    return _firestore
        .collection('votes')
        .where('decisionRef', isEqualTo: decisionRef)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vote.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<Vote>> getVotes() {
    return _firestore
        .collection('votes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Vote.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> deleteVotesForDecision(String decisionId) async {
    final decisionRef = _firestore.collection('decisions').doc(decisionId);
    final votes = await _firestore
        .collection('votes')
        .where('decisionRef', isEqualTo: decisionRef)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in votes.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> deleteUserVote(String decisionId, String userId) async {
    final decisionRef = _firestore.collection('decisions').doc(decisionId);
    final userRef = _firestore.collection('users').doc(userId);
    final votes = await _firestore
        .collection('votes')
        .where('decisionRef', isEqualTo: decisionRef)
        .where('userRef', isEqualTo: userRef)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in votes.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<VoteStatistics> getVoteStatistics(String decisionId) async {
    final decisionRef = _firestore.collection('decisions').doc(decisionId);
    final votes = await _firestore
        .collection('votes')
        .where('decisionRef', isEqualTo: decisionRef)
        .get();

    int votesForA = 0;
    int votesForB = 0;
    final Map<String, int> votesByCity = {};
    final Map<String, int> votesByAgeGroup = {};
    final Map<String, int> votesByGender = {};

    for (var doc in votes.docs) {
      final vote = Vote.fromMap({...doc.data(), 'id': doc.id});
      if (vote.option == 'A') {
        votesForA++;
      } else {
        votesForB++;
      }

      if (vote.demographics != null) {
        final demo = vote.demographics!;
        if (demo.city != null) {
          votesByCity[demo.city!] = (votesByCity[demo.city!] ?? 0) + 1;
        }
        if (demo.age != null) {
          final ageGroup = _getAgeGroup(demo.age!);
          votesByAgeGroup[ageGroup] = (votesByAgeGroup[ageGroup] ?? 0) + 1;
        }
        if (demo.gender != null) {
          votesByGender[demo.gender!] = (votesByGender[demo.gender!] ?? 0) + 1;
        }
      }
    }

    return VoteStatistics(
      totalVotes: votes.size,
      votesForA: votesForA,
      votesForB: votesForB,
      votesByCity: votesByCity,
      votesByAgeGroup: votesByAgeGroup,
      votesByGender: votesByGender,
    );
  }

  String _getAgeGroup(int age) {
    if (age < 18) return '18 altı';
    if (age < 25) return '18-24';
    if (age < 35) return '25-34';
    if (age < 45) return '35-44';
    if (age < 55) return '45-54';
    return '55+';
  }

  // Location Status Operations
  Future<String> createLocationStatus(LocationStatus locationStatus) async {
    final docRef =
        await _firestore.collection('locationStatuses').add(locationStatus.toMap());
    return docRef.id;
  }

  Future<void> addLocationFeedback(
      String locationStatusId, LocationFeedback feedback) async {
    await _firestore
        .collection('locationStatuses')
        .doc(locationStatusId)
        .collection('feedbacks')
        .doc(feedback.id)
        .set(feedback.toMap());
  }

  Stream<List<LocationFeedback>> getLocationFeedbacks(String locationStatusId) {
    return _firestore
        .collection('locationStatuses')
        .doc(locationStatusId)
        .collection('feedbacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LocationFeedback.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Virtual Plant Operations
  Stream<VirtualPlant> getVirtualPlant({String? groupId}) {
    final plantId = groupId ?? 'global';
    return _database.child('plants/$plantId').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return VirtualPlant.fromMap({
          ...Map<String, dynamic>.from(data),
          'id': plantId,
        });
      }
      // Return default plant if not exists
      return VirtualPlant(
        id: plantId,
        name: 'Ortak Bitki',
        waterLevel: 50.0,
        healthLevel: 50.0,
        lastWatered: DateTime.now(),
      );
    });
  }

  Future<void> waterPlant(String userId, {String? groupId}) async {
    final plantId = groupId ?? 'global';
    final plantRef = _database.child('plants/$plantId');

    // Get current plant state
    final snapshot = await plantRef.once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    double currentWaterLevel = 50.0;
    List<String> contributors = [];

    if (data != null) {
      currentWaterLevel = (data['waterLevel'] ?? 50.0).toDouble();
      contributors = List<String>.from(data['contributors'] ?? []);
    }

    // Increase water level (max 100)
    final newWaterLevel = (currentWaterLevel + 5).clamp(0.0, 100.0);

    // Add user to contributors if not already
    if (!contributors.contains(userId)) {
      contributors.add(userId);
    }

    // Update plant
    await plantRef.update({
      'waterLevel': newWaterLevel,
      'healthLevel': newWaterLevel, // Health follows water level
      'lastWatered': DateTime.now().toIso8601String(),
      'contributors': contributors,
      'groupId': groupId,
    });
  }

  // User Operations
  Future<void> createUser(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<AppUser?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return AppUser.fromMap({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  Future<void> updateUser(AppUser user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  // Achievement Operations
  Future<void> createAchievement(String userId, AchievementType type, {String? category}) async {
    // Aynı achievement'ın daha önce kazanılıp kazanılmadığını kontrol et
    final existingQuery = await _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.toString())
        .limit(1)
        .get();

    if (existingQuery.docs.isNotEmpty) {
      // Zaten kazanılmış, tekrar oluşturma
      return;
    }

    final achievement = {
      'userId': userId,
      'type': type.toString(),
      'category': category,
      'unlockedAt': DateTime.now().toIso8601String(),
    };

    await _firestore.collection('achievements').add(achievement);
  }

  Future<List<Achievement>> getUserAchievements(String userId) async {
    final snapshot = await _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .orderBy('unlockedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Achievement.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Stream<List<Achievement>> getUserAchievementsStream(String userId) {
    return _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Achievement.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<bool> hasAchievement(String userId, AchievementType type, {String? category}) async {
    final query = _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.toString());

    if (category != null) {
      query.where('category', isEqualTo: category);
    }

    final snapshot = await query.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }
}

