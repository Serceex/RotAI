import 'package:cloud_firestore/cloud_firestore.dart';

class Vote {
  final String id;
  final DocumentReference decisionRef;
  final DocumentReference userRef;
  final String option; // 'A' or 'B'
  final DateTime createdAt;
  final UserDemographics? demographics;

  Vote({
    required this.id,
    required this.decisionRef,
    required this.userRef,
    required this.option,
    required this.createdAt,
    this.demographics,
  });

  // Helper getter for decisionId (String)
  String get decisionId => decisionRef.id;
  
  // Helper getter for userId (String)
  String get userId => userRef.id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'decisionRef': decisionRef,
      'userRef': userRef,
      'option': option,
      'createdAt': createdAt.toIso8601String(),
      'demographics': demographics?.toMap(),
    };
  }

  factory Vote.fromMap(Map<String, dynamic> map) {
    return Vote(
      id: map['id'] ?? '',
      decisionRef: map['decisionRef'] as DocumentReference,
      userRef: map['userRef'] as DocumentReference,
      option: map['option'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      demographics: map['demographics'] != null
          ? UserDemographics.fromMap(map['demographics'])
          : null,
    );
  }
}

class UserDemographics {
  final String? city;
  final int? age;
  final String? gender;

  UserDemographics({
    this.city,
    this.age,
    this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'age': age,
      'gender': gender,
    };
  }

  factory UserDemographics.fromMap(Map<String, dynamic> map) {
    return UserDemographics(
      city: map['city'],
      age: map['age'],
      gender: map['gender'],
    );
  }
}

class VoteStatistics {
  final int totalVotes;
  final int votesForA;
  final int votesForB;
  final Map<String, int> votesByCity;
  final Map<String, int> votesByAgeGroup;
  final Map<String, int> votesByGender;

  VoteStatistics({
    required this.totalVotes,
    required this.votesForA,
    required this.votesForB,
    required this.votesByCity,
    required this.votesByAgeGroup,
    required this.votesByGender,
  });
}

