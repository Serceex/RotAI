import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expert.dart';
import '../models/expert_comment.dart';

class ExpertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Uzman oluştur
  Future<String> createExpert({
    required String userId,
    required List<String> expertise,
    required String bio,
  }) async {
    try {
      final expertData = {
        'userId': userId,
        'expertise': expertise,
        'bio': bio,
        'verified': false, // Admin tarafından onaylanacak
        'rating': 0.0,
        'totalReviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('experts').add(expertData);
      
      // User'ı da güncelle
      await _firestore.collection('users').doc(userId).update({
        'isExpert': true,
        'expertiseAreas': expertise,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Uzman oluşturulurken hata: $e');
    }
  }

  // Uzmanlık alanına göre uzmanları getir
  Future<List<Expert>> getExpertsByArea(String area) async {
    try {
      final snapshot = await _firestore
          .collection('experts')
          .where('expertise', arrayContains: area)
          .where('verified', isEqualTo: true)
          // .orderBy('rating', descending: true) // Index hatasını önlemek için kaldırıldı
          .get();

      final experts = <Expert>[];
      
      for (var doc in snapshot.docs) {
        final expertData = {...doc.data(), 'id': doc.id};
        
        // Kullanıcı bilgilerini getir
        final userId = expertData['userId'] as String;
        final userDoc = await _firestore.collection('users').doc(userId).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          expertData['displayName'] = userData['displayName'];
          expertData['email'] = userData['email'];
          expertData['photoUrl'] = userData['photoUrl'];
        }
        
        experts.add(Expert.fromMap(expertData));
      }

      return experts;
    } catch (e) {
      throw Exception('Uzmanlar getirilirken hata: $e');
    }
  }

  // Tüm doğrulanmış uzmanları getir
  Future<List<Expert>> getAllVerifiedExperts() async {
    try {
      final snapshot = await _firestore
          .collection('experts')
          .where('verified', isEqualTo: true)
          // .orderBy('rating', descending: true) // Index hatasını önlemek için kaldırıldı
          .limit(20)
          .get();

      final experts = <Expert>[];
      
      for (var doc in snapshot.docs) {
        final expertData = {...doc.data(), 'id': doc.id};
        
        // Kullanıcı bilgilerini getir
        final userId = expertData['userId'] as String;
        final userDoc = await _firestore.collection('users').doc(userId).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          expertData['displayName'] = userData['displayName'];
          expertData['email'] = userData['email'];
          expertData['photoUrl'] = userData['photoUrl'];
        }
        
        experts.add(Expert.fromMap(expertData));
      }

      return experts;
    } catch (e) {
      throw Exception('Uzmanlar getirilirken hata: $e');
    }
  }

  // Uzman ID'sine göre uzman getir
  Future<Expert?> getExpert(String expertId) async {
    try {
      final doc = await _firestore.collection('experts').doc(expertId).get();
      
      if (!doc.exists) return null;
      
      final expertData = {...doc.data()!, 'id': doc.id};
      
      // Kullanıcı bilgilerini getir
      final userId = expertData['userId'] as String;
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        expertData['displayName'] = userData['displayName'];
        expertData['email'] = userData['email'];
        expertData['photoUrl'] = userData['photoUrl'];
      }
      
      return Expert.fromMap(expertData);
    } catch (e) {
      throw Exception('Uzman getirilirken hata: $e');
    }
  }

  // Uzman yorumu ekle
  Future<String> addExpertComment({
    required String decisionId,
    required String expertId,
    required String comment,
  }) async {
    try {
      final commentData = {
        'decisionId': decisionId,
        'expertId': expertId,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
      };

      final docRef = await _firestore.collection('expert_comments').add(commentData);
      return docRef.id;
    } catch (e) {
      throw Exception('Yorum eklenirken hata: $e');
    }
  }

  // Decision için uzman yorumlarını getir (Stream)
  Stream<List<ExpertComment>> getExpertComments(String decisionId) {
    return _firestore
        .collection('expert_comments')
        .where('decisionId', isEqualTo: decisionId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final comments = <ExpertComment>[];
      
      for (var doc in snapshot.docs) {
        final commentData = {...doc.data(), 'id': doc.id};
        
        // Expert bilgilerini getir
        final expertId = commentData['expertId'] as String;
        final expert = await getExpert(expertId);
        
        if (expert != null) {
          commentData['expert'] = expert.toMap();
        }
        
        comments.add(ExpertComment.fromMap(commentData));
      }
      
      return comments;
    });
  }

  // Yorum beğen
  Future<void> likeComment(String commentId) async {
    try {
      await _firestore.collection('expert_comments').doc(commentId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Beğeni eklenirken hata: $e');
    }
  }

  // Kullanıcının uzman olup olmadığını kontrol et
  Future<Expert?> getExpertByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('experts')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final expertData = {...doc.data(), 'id': doc.id};
      
      // Kullanıcı bilgilerini getir
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        expertData['displayName'] = userData['displayName'];
        expertData['email'] = userData['email'];
        expertData['photoUrl'] = userData['photoUrl'];
      }
      
      return Expert.fromMap(expertData);
    } catch (e) {
      throw Exception('Uzman kontrolü yapılırken hata: $e');
    }
  }

  // Uzman başvurusunu onayla (Admin)
  Future<void> verifyExpert(String expertId) async {
    try {
      await _firestore.collection('experts').doc(expertId).update({
        'verified': true,
      });
    } catch (e) {
      throw Exception('Uzman onaylanırken hata: $e');
    }
  }

  // Test için demo uzman oluştur
  Future<void> createDemoExpert() async {
    try {
      // Önce mevcut kullanıcıyı al veya rastgele bir ID kullan
      final userId = 'demo_expert_user';
      
      // Kullanıcı oluştur (eğer yoksa)
      await _firestore.collection('users').doc(userId).set({
        'displayName': 'Dr. AI Uzmanı',
        'email': 'uzman@ai.com',
        'photoUrl': '',
        'isExpert': true,
        'expertiseAreas': ['Kariyer', 'Teknoloji'],
      }, SetOptions(merge: true));

      // Uzman profili oluştur
      await _firestore.collection('experts').add({
        'userId': userId,
        'expertise': ['Kariyer', 'Teknoloji', 'Yatırım'],
        'bio': 'Yapay zeka ve kariyer danışmanlığı konusunda 10 yıllık deneyim.',
        'verified': true,
        'rating': 4.8,
        'totalReviews': 120,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Demo uzman oluşturulurken hata: $e');
    }
  }
}
