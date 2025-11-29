import 'package:cloud_firestore/cloud_firestore.dart';

class LocationStatus {
  final String id;
  final DocumentReference decisionRef;
  final String locationName;
  final double latitude;
  final double longitude;
  final List<LocationFeedback> feedbacks;
  final DateTime createdAt;

  LocationStatus({
    required this.id,
    required this.decisionRef,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.feedbacks,
    required this.createdAt,
  });

  // Helper getter for decisionId (String)
  String get decisionId => decisionRef.id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'decisionRef': decisionRef,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'feedbacks': feedbacks.map((f) => f.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LocationStatus.fromMap(Map<String, dynamic> map) {
    // decisionRef DocumentReference olarak gelir veya String'den oluşturulur
    DocumentReference decisionRef;
    if (map['decisionRef'] is DocumentReference) {
      decisionRef = map['decisionRef'] as DocumentReference;
    } else if (map['decisionId'] != null) {
      // Backward compatibility: Eğer decisionId String olarak gelirse
      decisionRef = FirebaseFirestore.instance.collection('decisions').doc(map['decisionId']);
    } else {
      throw Exception('decisionRef or decisionId must be provided');
    }

    return LocationStatus(
      id: map['id'] ?? '',
      decisionRef: decisionRef,
      locationName: map['locationName'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      feedbacks: (map['feedbacks'] as List<dynamic>?)
              ?.map((f) => LocationFeedback.fromMap(f as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class LocationFeedback {
  final String id;
  final DocumentReference userRef;
  final bool isCrowded; // true = kalabalık, false = sakin
  final String? photoUrl;
  final String? comment;
  final DateTime createdAt;

  LocationFeedback({
    required this.id,
    required this.userRef,
    required this.isCrowded,
    this.photoUrl,
    this.comment,
    required this.createdAt,
  });

  // Helper getter for userId (String)
  String get userId => userRef.id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userRef': userRef,
      'isCrowded': isCrowded,
      'photoUrl': photoUrl,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LocationFeedback.fromMap(Map<String, dynamic> map) {
    // userRef DocumentReference olarak gelir veya String'den oluşturulur
    DocumentReference userRef;
    if (map['userRef'] is DocumentReference) {
      userRef = map['userRef'] as DocumentReference;
    } else if (map['userId'] != null) {
      // Backward compatibility: Eğer userId String olarak gelirse
      userRef = FirebaseFirestore.instance.collection('users').doc(map['userId']);
    } else {
      throw Exception('userRef or userId must be provided');
    }

    return LocationFeedback(
      id: map['id'] ?? '',
      userRef: userRef,
      isCrowded: map['isCrowded'] ?? false,
      photoUrl: map['photoUrl'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

