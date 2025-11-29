class RoomHint {
  final String id;
  final String roomId;
  final String hintText;
  final int hintNumber; // 1, 2, 3... (kaçıncı ipucu)
  final DateTime createdAt;

  RoomHint({
    required this.id,
    required this.roomId,
    required this.hintText,
    required this.hintNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'hintText': hintText,
      'hintNumber': hintNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RoomHint.fromMap(Map<String, dynamic> map) {
    return RoomHint(
      id: map['id'] ?? '',
      roomId: map['roomId'] ?? '',
      hintText: map['hintText'] ?? '',
      hintNumber: map['hintNumber'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

