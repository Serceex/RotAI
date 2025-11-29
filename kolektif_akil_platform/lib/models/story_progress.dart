import 'package:cloud_firestore/cloud_firestore.dart';

class StoryProgress {
  final String id;
  final String storyId;
  final DocumentReference userRef;
  final int currentRoomIndex; // Hangi odada (0-based)
  final List<String> completedRoomIds;
  final int totalScore;
  final DateTime startedAt;
  final DateTime? completedAt;

  StoryProgress({
    required this.id,
    required this.storyId,
    required this.userRef,
    this.currentRoomIndex = 0,
    this.completedRoomIds = const [],
    this.totalScore = 0,
    required this.startedAt,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storyId': storyId,
      'userRef': userRef,
      'currentRoomIndex': currentRoomIndex,
      'completedRoomIds': completedRoomIds,
      'totalScore': totalScore,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory StoryProgress.fromMap(Map<String, dynamic> map) {
    DocumentReference userRef;
    if (map['userRef'] is DocumentReference) {
      userRef = map['userRef'] as DocumentReference;
    } else {
      userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(map['userRef'].toString());
    }

    return StoryProgress(
      id: map['id'] ?? '',
      storyId: map['storyId'] ?? '',
      userRef: userRef,
      currentRoomIndex: map['currentRoomIndex'] ?? 0,
      completedRoomIds: List<String>.from(map['completedRoomIds'] ?? []),
      totalScore: map['totalScore'] ?? 0,
      startedAt: DateTime.parse(map['startedAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }
}

