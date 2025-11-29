import 'package:cloud_firestore/cloud_firestore.dart';
import 'expert.dart';

class ExpertComment {
  final String id;
  final String decisionId;
  final String expertId;
  final String comment;
  final DateTime createdAt;
  final int likes;
  
  // Expert bilgileri (join için)
  final Expert? expert;

  ExpertComment({
    required this.id,
    required this.decisionId,
    required this.expertId,
    required this.comment,
    required this.createdAt,
    this.likes = 0,
    this.expert,
  });

  factory ExpertComment.fromMap(Map<String, dynamic> map) {
    return ExpertComment(
      id: map['id'] ?? '',
      decisionId: map['decisionId'] ?? '',
      expertId: map['expertId'] ?? '',
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      likes: map['likes'] ?? 0,
      expert: map['expert'] != null ? Expert.fromMap(map['expert']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'decisionId': decisionId,
      'expertId': expertId,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }

  ExpertComment copyWith({
    String? id,
    String? decisionId,
    String? expertId,
    String? comment,
    DateTime? createdAt,
    int? likes,
    Expert? expert,
  }) {
    return ExpertComment(
      id: id ?? this.id,
      decisionId: decisionId ?? this.decisionId,
      expertId: expertId ?? this.expertId,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      expert: expert ?? this.expert,
    );
  }
}
