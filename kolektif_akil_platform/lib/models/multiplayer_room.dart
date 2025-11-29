import 'package:cloud_firestore/cloud_firestore.dart';

class MultiplayerRoom {
  final String id;
  final String roomId; // Escape room ID
  final DocumentReference hostRef; // Oda sahibi
  final List<DocumentReference> players; // Oyuncular
  final Map<String, String> votes; // userId -> 'A' veya 'B'
  final bool isStarted;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  MultiplayerRoom({
    required this.id,
    required this.roomId,
    required this.hostRef,
    this.players = const [],
    this.votes = const {},
    this.isStarted = false,
    this.isCompleted = false,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  int get playerCount => players.length;
  bool get allVoted => votes.length == players.length && players.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'hostRef': hostRef,
      'players': players,
      'votes': votes,
      'isStarted': isStarted,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory MultiplayerRoom.fromMap(Map<String, dynamic> map) {
    DocumentReference hostRef;
    if (map['hostRef'] is DocumentReference) {
      hostRef = map['hostRef'] as DocumentReference;
    } else {
      hostRef = FirebaseFirestore.instance
          .collection('users')
          .doc(map['hostRef'].toString());
    }

    List<DocumentReference> players = [];
    if (map['players'] != null) {
      players = (map['players'] as List).map((p) {
        if (p is DocumentReference) {
          return p;
        } else {
          return FirebaseFirestore.instance.collection('users').doc(p.toString());
        }
      }).toList();
    }

    Map<String, String> votes = {};
    if (map['votes'] != null) {
      votes = Map<String, String>.from(map['votes']);
    }

    return MultiplayerRoom(
      id: map['id'] ?? '',
      roomId: map['roomId'] ?? '',
      hostRef: hostRef,
      players: players,
      votes: votes,
      isStarted: map['isStarted'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }
}

