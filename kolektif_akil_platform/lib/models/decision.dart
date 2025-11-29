import 'package:cloud_firestore/cloud_firestore.dart';

class Decision {
  final String id;
  final DocumentReference userRef;
  final String question;
  final String? optionA;
  final String? optionB;
  final DecisionTree? decisionTree;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSubmittedToVote;

  Decision({
    required this.id,
    required this.userRef,
    required this.question,
    this.optionA,
    this.optionB,
    this.decisionTree,
    required this.createdAt,
    this.updatedAt,
    this.isSubmittedToVote = false,
  });

  // Helper getter for userId (String)
  String get userId => userRef.id;

  // Doğru cevabı döndürür ('A' veya 'B')
  String? get correctAnswer => decisionTree?.recommendedOption;

  // Kullanıcının seçtiği cevabın doğru olup olmadığını kontrol eder
  bool isCorrectAnswer(String selectedOption) {
    final correct = correctAnswer;
    if (correct == null) return false;
    
    // 'A', 'optionA', 'Seçenek A' gibi farklı formatları kontrol et
    final normalizedSelected = selectedOption.toUpperCase().trim();
    final normalizedCorrect = correct.toUpperCase().trim();
    
    if (normalizedCorrect == 'A' || normalizedCorrect == 'OPTIONA' || normalizedCorrect == 'SEÇENEK A') {
      return normalizedSelected == 'A' || 
             normalizedSelected == 'OPTIONA' || 
             normalizedSelected == 'SEÇENEK A' ||
             normalizedSelected == 'OPTION A';
    } else if (normalizedCorrect == 'B' || normalizedCorrect == 'OPTIONB' || normalizedCorrect == 'SEÇENEK B') {
      return normalizedSelected == 'B' || 
             normalizedSelected == 'OPTIONB' || 
             normalizedSelected == 'SEÇENEK B' ||
             normalizedSelected == 'OPTION B';
    }
    
    return normalizedSelected == normalizedCorrect;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userRef': userRef,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'decisionTree': decisionTree?.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSubmittedToVote': isSubmittedToVote,
    };
  }

  factory Decision.fromMap(Map<String, dynamic> map) {
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

    return Decision(
      id: map['id'] ?? '',
      userRef: userRef,
      question: map['question'] ?? '',
      optionA: map['optionA'],
      optionB: map['optionB'],
      decisionTree: map['decisionTree'] != null
          ? DecisionTree.fromMap(map['decisionTree'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      isSubmittedToVote: map['isSubmittedToVote'] ?? false,
    );
  }
}

class DecisionTree {
  final String analysis;
  final DecisionNode rootNode;
  final List<String> risks;
  final List<String> benefits;
  final String? recommendedOption; // 'A' veya 'B' - hangi seçenek öneriliyor

  DecisionTree({
    required this.analysis,
    required this.rootNode,
    required this.risks,
    required this.benefits,
    this.recommendedOption,
  });

  Map<String, dynamic> toMap() {
    return {
      'analysis': analysis,
      'rootNode': rootNode.toMap(),
      'risks': risks,
      'benefits': benefits,
      'recommendedOption': recommendedOption,
    };
  }

  factory DecisionTree.fromMap(Map<String, dynamic> map) {
    return DecisionTree(
      analysis: map['analysis'] ?? '',
      rootNode: DecisionNode.fromMap(map['rootNode']),
      risks: List<String>.from(map['risks'] ?? []),
      benefits: List<String>.from(map['benefits'] ?? []),
      recommendedOption: map['recommendedOption'] as String?,
    );
  }
}

class DecisionNode {
  final String id;
  final String label;
  final String? description;
  final List<DecisionNode> children;
  final String? outcome;

  DecisionNode({
    required this.id,
    required this.label,
    this.description,
    this.children = const [],
    this.outcome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'children': children.map((c) => c.toMap()).toList(),
      'outcome': outcome,
    };
  }

  factory DecisionNode.fromMap(Map<String, dynamic> map) {
    return DecisionNode(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      description: map['description'],
      children: (map['children'] as List<dynamic>?)
              ?.map((c) => DecisionNode.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      outcome: map['outcome'],
    );
  }
}

