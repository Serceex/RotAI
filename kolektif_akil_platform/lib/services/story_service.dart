import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story.dart';
import '../models/story_progress.dart';
import '../models/escape_room.dart';
import 'escape_room_service.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EscapeRoomService _roomService = EscapeRoomService();

  // Yeni hikaye oluştur
  Future<String> createStory(Story story) async {
    final docRef = _firestore.collection('stories').doc();
    await docRef.set(story.toMap());
    return docRef.id;
  }

  // Tüm hikayeleri getir
  Stream<List<Story>> getStories({bool publishedOnly = true}) {
    Query<Map<String, dynamic>> query = _firestore.collection('stories');

    if (publishedOnly) {
      query = query.where('isPublished', isEqualTo: true);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Story.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Tek bir hikaye getir
  Future<Story?> getStory(String storyId) async {
    final doc = await _firestore.collection('stories').doc(storyId).get();
    if (doc.exists) {
      return Story.fromMap({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  // Hikaye ilerlemesi başlat
  Future<String> startStoryProgress(
      String storyId, String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final progress = StoryProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      storyId: storyId,
      userRef: userRef,
      currentRoomIndex: 0,
      startedAt: DateTime.now(),
    );

    final docRef = _firestore.collection('story_progress').doc();
    await docRef.set(progress.toMap());
    return docRef.id;
  }

  // Hikaye ilerlemesi getir
  Future<StoryProgress?> getStoryProgress(
      String storyId, String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final query = await _firestore
        .collection('story_progress')
        .where('storyId', isEqualTo: storyId)
        .where('userRef', isEqualTo: userRef)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return StoryProgress.fromMap(
          {...query.docs.first.data(), 'id': query.docs.first.id});
    }
    return null;
  }

  // Oda tamamlandı - ilerlemeyi güncelle
  Future<void> completeRoomInStory(
      String progressId, String roomId, int score) async {
    final progressDoc =
        await _firestore.collection('story_progress').doc(progressId).get();
    if (!progressDoc.exists) return;

    final progressData = progressDoc.data()!;
    final storyId = progressData['storyId'] as String;
    final story = await getStory(storyId);
    if (story == null) return;

    final completedRooms =
        List<String>.from(progressData['completedRoomIds'] ?? []);
    if (!completedRooms.contains(roomId)) {
      completedRooms.add(roomId);
    }

    final currentIndex = progressData['currentRoomIndex'] as int;
    final newIndex = currentIndex + 1;
    final totalScore = (progressData['totalScore'] as int? ?? 0) + score;

    final isCompleted = newIndex >= story.roomIds.length;

    await _firestore.collection('story_progress').doc(progressId).update({
      'completedRoomIds': completedRooms,
      'currentRoomIndex': newIndex,
      'totalScore': totalScore,
      if (isCompleted) 'completedAt': DateTime.now().toIso8601String(),
    });
  }

  // Hikayenin bir sonraki odasını getir
  Future<EscapeRoom?> getNextRoom(String storyId, int currentIndex) async {
    final story = await getStory(storyId);
    if (story == null || currentIndex >= story.roomIds.length) {
      return null;
    }

    final roomId = story.roomIds[currentIndex];
    return await _roomService.getRoom(roomId);
  }
}

