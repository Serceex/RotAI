import 'package:cloud_firestore/cloud_firestore.dart';

class RoomSession {
  final String id;
  final String roomId;
  final DocumentReference userRef;
  final String? selectedOption; // 'A' veya 'B'
  final bool isCompleted;
  final bool isCorrect;
  final int timeSpent; // saniye cinsinden
  final int hintsUsed;
  final int score;
  final DateTime startedAt;
  final DateTime? completedAt;

  RoomSession({
    required this.id,
    required this.roomId,
    required this.userRef,
    this.selectedOption,
    this.isCompleted = false,
    this.isCorrect = false,
    this.timeSpent = 0,
    this.hintsUsed = 0,
    this.score = 0,
    required this.startedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'userRef': userRef,
      'selectedOption': selectedOption,
      'isCompleted': isCompleted,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'hintsUsed': hintsUsed,
      'score': score,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory RoomSession.fromMap(Map<String, dynamic> map) {
    DocumentReference userRef;
    if (map['userRef'] is DocumentReference) {
      userRef = map['userRef'] as DocumentReference;
    } else {
      userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(map['userRef'].toString());
    }

    return RoomSession(
      id: map['id'] ?? '',
      roomId: map['roomId'] ?? '',
      userRef: userRef,
      selectedOption: map['selectedOption'] as String?,
      isCompleted: map['isCompleted'] ?? false,
      isCorrect: map['isCorrect'] ?? false,
      timeSpent: map['timeSpent'] ?? 0,
      hintsUsed: map['hintsUsed'] ?? 0,
      score: map['score'] ?? 0,
      startedAt: DateTime.parse(map['startedAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }
}

