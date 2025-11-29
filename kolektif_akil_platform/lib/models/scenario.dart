import 'package:cloud_firestore/cloud_firestore.dart';

class Scenario {
  final String id;
  final String decisionId;
  final String title;
  final String description;
  final String selectedOption; // 'A' veya 'B'
  final Map<String, dynamic> parameters; // Senaryo parametreleri
  final String? result; // Senaryo sonucu
  final DocumentReference? createdBy;
  final DateTime createdAt;

  Scenario({
    required this.id,
    required this.decisionId,
    required this.title,
    required this.description,
    required this.selectedOption,
    this.parameters = const {},
    this.result,
    this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'decisionId': decisionId,
      'title': title,
      'description': description,
      'selectedOption': selectedOption,
      'parameters': parameters,
      'result': result,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Scenario.fromMap(Map<String, dynamic> map) {
    DocumentReference? createdBy;
    if (map['createdBy'] is DocumentReference) {
      createdBy = map['createdBy'] as DocumentReference;
    } else if (map['createdBy'] != null) {
      createdBy = FirebaseFirestore.instance
          .collection('users')
          .doc(map['createdBy'].toString());
    }

    return Scenario(
      id: map['id'] ?? '',
      decisionId: map['decisionId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      selectedOption: map['selectedOption'] ?? '',
      parameters: Map<String, dynamic>.from(map['parameters'] ?? {}),
      result: map['result'] as String?,
      createdBy: createdBy,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

