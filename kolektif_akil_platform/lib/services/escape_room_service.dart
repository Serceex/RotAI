import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/escape_room.dart';
import '../models/room_session.dart';

class EscapeRoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yeni bir escape room oluştur
  Future<String> createRoom(EscapeRoom room) async {
    final docRef = _firestore.collection('escape_rooms').doc();
    await docRef.set(room.toMap());
    return docRef.id;
  }

  // Escape room'u güncelle
  Future<void> updateRoom(String roomId, Map<String, dynamic> updates) async {
    await _firestore.collection('escape_rooms').doc(roomId).update(updates);
  }

  // Escape room'u sil
  Future<void> deleteRoom(String roomId) async {
    await _firestore.collection('escape_rooms').doc(roomId).delete();
  }

  // Tüm escape room'ları getir
  Stream<List<EscapeRoom>> getRooms({String? category}) {
    Query<Map<String, dynamic>> query = _firestore.collection('escape_rooms');

    if (category != null && category.isNotEmpty && category != 'all') {
      query = query.where('category', isEqualTo: category);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EscapeRoom.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Tek bir escape room getir
  Future<EscapeRoom?> getRoom(String roomId) async {
    final doc = await _firestore.collection('escape_rooms').doc(roomId).get();
    if (doc.exists) {
      return EscapeRoom.fromMap({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  // Session oluştur
  Future<String> createSession(RoomSession session) async {
    final docRef = _firestore.collection('room_sessions').doc();
    await docRef.set(session.toMap());
    return docRef.id;
  }

  // Session güncelle
  Future<void> updateSession(
      String sessionId, Map<String, dynamic> updates) async {
    await _firestore.collection('room_sessions').doc(sessionId).update(updates);
  }

  // Kullanıcının bir room için session'ını getir
  Future<RoomSession?> getUserSession(String roomId, String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final query = await _firestore
        .collection('room_sessions')
        .where('roomId', isEqualTo: roomId)
        .where('userRef', isEqualTo: userRef)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return RoomSession.fromMap(
          {...query.docs.first.data(), 'id': query.docs.first.id});
    }
    return null;
  }

  // Kullanıcının tüm session'larını getir
  Stream<List<RoomSession>> getUserSessions(String userId) {
    final userRef = _firestore.collection('users').doc(userId);
    return _firestore
        .collection('room_sessions')
        .where('userRef', isEqualTo: userRef)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                RoomSession.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Leaderboard için en yüksek skorları getir
  Future<List<RoomSession>> getLeaderboard({int limit = 10}) async {
    final query = await _firestore
        .collection('room_sessions')
        .where('isCompleted', isEqualTo: true)
        .orderBy('score', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => RoomSession.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }
}

