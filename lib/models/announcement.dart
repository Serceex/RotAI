class Announcement {
  final String id;
  final String title;
  final String message;
  final String? type; // 'info', 'success', 'warning', 'update'
  final DateTime createdAt;
  final bool isActive;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }
}

