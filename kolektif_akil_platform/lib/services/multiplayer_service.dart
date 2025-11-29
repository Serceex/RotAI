import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/multiplayer_room.dart';

class MultiplayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Yeni multiplayer room oluştur
  Future<String> createMultiplayerRoom(MultiplayerRoom room) async {
    final docRef = _firestore.collection('multiplayer_rooms').doc();
    await docRef.set(room.toMap());

    // Realtime Database'de de oluştur (hızlı senkronizasyon için)
    await _database.child('multiplayer_rooms/${docRef.id}').set({
      'id': docRef.id,
      'roomId': room.roomId,
      'hostId': room.hostRef.id,
      'playerIds': [],
      'votes': {},
      'isStarted': false,
      'isCompleted': false,
    });

    return docRef.id;
  }

  // Multiplayer room'u getir
  Future<MultiplayerRoom?> getMultiplayerRoom(String roomId) async {
    final doc =
        await _firestore.collection('multiplayer_rooms').doc(roomId).get();
    if (doc.exists) {
      return MultiplayerRoom.fromMap({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  // Realtime stream (hızlı güncellemeler için)
  Stream<Map<String, dynamic>?> getMultiplayerRoomStream(String roomId) {
    return _database.child('multiplayer_rooms/$roomId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    });
  }

  // Oyuncu ekle
  Future<void> addPlayer(String roomId, String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final roomDoc =
        _firestore.collection('multiplayer_rooms').doc(roomId);
    final room = await roomDoc.get();

    if (room.exists) {
      final roomData = room.data()!;
      final players = List<DocumentReference>.from(
          (roomData['players'] as List?) ?? []);

      if (!players.any((p) => p.id == userId)) {
        players.add(userRef);
        await roomDoc.update({'players': players});

        // Realtime Database'de de güncelle
        await _database.child('multiplayer_rooms/$roomId/playerIds').set(
            players.map((p) => p.id).toList());
      }
    }
  }

  // Oyuncu çıkar
  Future<void> removePlayer(String roomId, String userId) async {
    final roomDoc =
        _firestore.collection('multiplayer_rooms').doc(roomId);
    final room = await roomDoc.get();

    if (room.exists) {
      final roomData = room.data()!;
      final players = List<DocumentReference>.from(
          (roomData['players'] as List?) ?? []);

      players.removeWhere((p) => p.id == userId);
      await roomDoc.update({'players': players});

      // Realtime Database'de de güncelle
      await _database.child('multiplayer_rooms/$roomId/playerIds').set(
          players.map((p) => p.id).toList());
    }
  }

  // Oy kullan
  Future<void> vote(String roomId, String userId, String option) async {
    final roomDoc =
        _firestore.collection('multiplayer_rooms').doc(roomId);
    final room = await roomDoc.get();

    if (room.exists) {
      final roomData = room.data()!;
      final votes = Map<String, String>.from(roomData['votes'] ?? {});

      votes[userId] = option;
      await roomDoc.update({'votes': votes});

      // Realtime Database'de de güncelle
      await _database.child('multiplayer_rooms/$roomId/votes').set(votes);
    }
  }

  // Oyunu başlat
  Future<void> startGame(String roomId) async {
    await _firestore.collection('multiplayer_rooms').doc(roomId).update({
      'isStarted': true,
      'startedAt': DateTime.now().toIso8601String(),
    });

    await _database.child('multiplayer_rooms/$roomId').update({
      'isStarted': true,
      'startedAt': DateTime.now().toIso8601String(),
    });
  }

  // Oyunu tamamla
  Future<void> completeGame(String roomId) async {
    await _firestore.collection('multiplayer_rooms').doc(roomId).update({
      'isCompleted': true,
      'completedAt': DateTime.now().toIso8601String(),
    });

    await _database.child('multiplayer_rooms/$roomId').update({
      'isCompleted': true,
      'completedAt': DateTime.now().toIso8601String(),
    });
  }
}

