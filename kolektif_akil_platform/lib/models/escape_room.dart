import 'package:cloud_firestore/cloud_firestore.dart';

enum DifficultyLevel {
  easy(label: 'Kolay', timeLimit: 300, hintCount: 5, baseScore: 100),
  medium(label: 'Orta', timeLimit: 180, hintCount: 3, baseScore: 200),
  hard(label: 'Zor', timeLimit: 120, hintCount: 2, baseScore: 300),
  expert(label: 'Uzman', timeLimit: 60, hintCount: 1, baseScore: 500);

  final String label;
  final int timeLimit; // saniye cinsinden
  final int hintCount;
  final int baseScore;

  const DifficultyLevel({
    required this.label,
    required this.timeLimit,
    required this.hintCount,
    required this.baseScore,
  });
}

class EscapeRoom {
  final String id;
  final String title;
  final String question;
  final String optionA;
  final String optionB;
  final String? decisionId; // Eğer mevcut bir decision'dan oluşturulduysa
  final DifficultyLevel difficulty;
  final String? category;
  final DocumentReference? createdBy;
  final DateTime createdAt;
  final String? storyId; // Eğer bir hikayenin parçasıysa
  final int? storyOrder; // Hikaye içindeki sıra

  EscapeRoom({
    required this.id,
    required this.title,
    required this.question,
    required this.optionA,
    required this.optionB,
    this.decisionId,
    required this.difficulty,
    this.category,
    this.createdBy,
    required this.createdAt,
    this.storyId,
    this.storyOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'decisionId': decisionId,
      'difficulty': difficulty.name,
      'category': category,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'storyId': storyId,
      'storyOrder': storyOrder,
    };
  }

  factory EscapeRoom.fromMap(Map<String, dynamic> map) {
    DocumentReference? createdBy;
    if (map['createdBy'] is DocumentReference) {
      createdBy = map['createdBy'] as DocumentReference;
    } else if (map['createdBy'] != null) {
      createdBy = FirebaseFirestore.instance
          .collection('users')
          .doc(map['createdBy'].toString());
    }

    return EscapeRoom(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      question: map['question'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      decisionId: map['decisionId'] as String?,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      category: map['category'] as String?,
      createdBy: createdBy,
      createdAt: DateTime.parse(map['createdAt']),
      storyId: map['storyId'] as String?,
      storyOrder: map['storyOrder'] as int?,
    );
  }
}

