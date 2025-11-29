import 'package:cloud_firestore/cloud_firestore.dart';

class Expert {
  final String id;
  final String userId;
  final List<String> expertise;
  final String bio;
  final bool verified;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;
  
  // Kullanıcı bilgileri (join için)
  final String? displayName;
  final String? email;
  final String? photoUrl;

  Expert({
    required this.id,
    required this.userId,
    required this.expertise,
    required this.bio,
    this.verified = false,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.createdAt,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  factory Expert.fromMap(Map<String, dynamic> map) {
    return Expert(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      expertise: List<String>.from(map['expertise'] ?? []),
      bio: map['bio'] ?? '',
      verified: map['verified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      displayName: map['displayName'],
      email: map['email'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'expertise': expertise,
      'bio': bio,
      'verified': verified,
      'rating': rating,
      'totalReviews': totalReviews,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Expert copyWith({
    String? id,
    String? userId,
    List<String>? expertise,
    String? bio,
    bool? verified,
    double? rating,
    int? totalReviews,
    DateTime? createdAt,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return Expert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      expertise: expertise ?? this.expertise,
      bio: bio ?? this.bio,
      verified: verified ?? this.verified,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
