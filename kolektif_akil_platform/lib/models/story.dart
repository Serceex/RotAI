import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String title;
  final String description;
  final List<String> roomIds; // Escape room ID'leri sırayla
  final DocumentReference? createdBy;
  final DateTime createdAt;
  final bool isPublished;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.roomIds,
    this.createdBy,
    required this.createdAt,
    this.isPublished = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'roomIds': roomIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPublished': isPublished,
    };
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    DocumentReference? createdBy;
    if (map['createdBy'] is DocumentReference) {
      createdBy = map['createdBy'] as DocumentReference;
    } else if (map['createdBy'] != null) {
      createdBy = FirebaseFirestore.instance
          .collection('users')
          .doc(map['createdBy'].toString());
    }

    return Story(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      roomIds: List<String>.from(map['roomIds'] ?? []),
      createdBy: createdBy,
      createdAt: DateTime.parse(map['createdAt']),
      isPublished: map['isPublished'] ?? false,
    );
  }
}

