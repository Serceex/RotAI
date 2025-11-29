import 'package:cloud_firestore/cloud_firestore.dart';

class ExpertRequest {
  final String id;
  final String decisionId;
  final DocumentReference userRef;
  final DocumentReference? expertRef;
  final String? comment;
  final String status; // 'pending', 'accepted', 'rejected', 'completed'
  final DateTime createdAt;
  final DateTime? respondedAt;

  ExpertRequest({
    required this.id,
    required this.decisionId,
    required this.userRef,
    this.expertRef,
    this.comment,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'decisionId': decisionId,
      'userRef': userRef,
      'expertRef': expertRef,
      'comment': comment,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  factory ExpertRequest.fromMap(Map<String, dynamic> map) {
    DocumentReference userRef;
    if (map['userRef'] is DocumentReference) {
      userRef = map['userRef'] as DocumentReference;
    } else {
      userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(map['userRef'].toString());
    }

    DocumentReference? expertRef;
    if (map['expertRef'] != null) {
      if (map['expertRef'] is DocumentReference) {
        expertRef = map['expertRef'] as DocumentReference;
      } else {
        expertRef = FirebaseFirestore.instance
            .collection('users')
            .doc(map['expertRef'].toString());
      }
    }

    return ExpertRequest(
      id: map['id'] ?? '',
      decisionId: map['decisionId'] ?? '',
      userRef: userRef,
      expertRef: expertRef,
      comment: map['comment'] as String?,
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      respondedAt: map['respondedAt'] != null
          ? DateTime.parse(map['respondedAt'])
          : null,
    );
  }
}

