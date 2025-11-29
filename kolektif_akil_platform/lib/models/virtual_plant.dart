class VirtualPlant {
  final String id;
  final String name;
  final double waterLevel; // 0-100
  final double healthLevel; // 0-100
  final DateTime lastWatered;
  final List<String> contributors; // User IDs who watered
  final String? groupId; // For company/group plants

  VirtualPlant({
    required this.id,
    required this.name,
    required this.waterLevel,
    required this.healthLevel,
    required this.lastWatered,
    this.contributors = const [],
    this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'waterLevel': waterLevel,
      'healthLevel': healthLevel,
      'lastWatered': lastWatered.toIso8601String(),
      'contributors': contributors,
      'groupId': groupId,
    };
  }

  factory VirtualPlant.fromMap(Map<String, dynamic> map) {
    return VirtualPlant(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Ortak Bitki',
      waterLevel: (map['waterLevel'] ?? 0.0).toDouble(),
      healthLevel: (map['healthLevel'] ?? 100.0).toDouble(),
      lastWatered: DateTime.parse(map['lastWatered']),
      contributors: List<String>.from(map['contributors'] ?? []),
      groupId: map['groupId'],
    );
  }

  VirtualPlant copyWith({
    String? id,
    String? name,
    double? waterLevel,
    double? healthLevel,
    DateTime? lastWatered,
    List<String>? contributors,
    String? groupId,
  }) {
    return VirtualPlant(
      id: id ?? this.id,
      name: name ?? this.name,
      waterLevel: waterLevel ?? this.waterLevel,
      healthLevel: healthLevel ?? this.healthLevel,
      lastWatered: lastWatered ?? this.lastWatered,
      contributors: contributors ?? this.contributors,
      groupId: groupId ?? this.groupId,
    );
  }
}

