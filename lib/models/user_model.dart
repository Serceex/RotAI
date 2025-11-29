class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? city;
  final int? age;
  final String? gender;
  final DateTime createdAt;
  final bool shareLocation;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.city,
    this.age,
    this.gender,
    required this.createdAt,
    this.shareLocation = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'city': city,
      'age': age,
      'gender': gender,
      'createdAt': createdAt.toIso8601String(),
      'shareLocation': shareLocation,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      city: map['city'],
      age: map['age'],
      gender: map['gender'],
      createdAt: DateTime.parse(map['createdAt']),
      shareLocation: map['shareLocation'] ?? false,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? city,
    int? age,
    String? gender,
    DateTime? createdAt,
    bool? shareLocation,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      city: city ?? this.city,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      shareLocation: shareLocation ?? this.shareLocation,
    );
  }
}

