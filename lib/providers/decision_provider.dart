import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/decision.dart';
import '../models/vote.dart';
import '../services/firebase_service.dart';
import '../services/gemini_service.dart';

class DecisionProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final GeminiService _geminiService;

  DecisionProvider({required String geminiApiKey})
      : _geminiService = GeminiService(apiKey: geminiApiKey);

  Decision? _currentDecision;
  bool _isAnalyzing = false;
  VoteStatistics? _voteStatistics;
  List<Vote> _votes = [];

  Decision? get currentDecision => _currentDecision;
  bool get isAnalyzing => _isAnalyzing;
  VoteStatistics? get voteStatistics => _voteStatistics;
  List<Vote> get votes => _votes;

  Future<Decision> analyzeDecision(
    String question, {
    required String userId,
    required String optionA,
    required String optionB,
    required String category,
  }) async {
    _isAnalyzing = true;
    notifyListeners();

    try {
      final decisionTree = await _geminiService.analyzeDecision(question);

      // Kullanıcı ID'si ile userRef oluştur
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final decision = Decision(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userRef: userRef,
        question: question,
        optionA: optionA,
        optionB: optionB,
        category: category,
        decisionTree: decisionTree,
        createdAt: DateTime.now(),
      );

      _currentDecision = decision;
      _isAnalyzing = false;
      notifyListeners();

      return decision;
    } catch (e) {
      _isAnalyzing = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String> saveDecision(Decision decision) async {
    // Decision'ı oylamaya sunulmuş olarak işaretle
    final decisionToSave = Decision(
      id: decision.id,
      userRef: decision.userRef,
      question: decision.question,
      optionA: decision.optionA,
      optionB: decision.optionB,
      decisionTree: decision.decisionTree,
      createdAt: decision.createdAt,
      updatedAt: decision.updatedAt,
      isSubmittedToVote: true, // Oylamaya sunuldu olarak işaretle
      category: decision.category,
    );
    final decisionId = await _firebaseService.createDecision(decisionToSave);
    _currentDecision = decisionToSave;
    notifyListeners();
    return decisionId;
  }

  Future<void> toggleVoteSubmission(String decisionId, bool submitToVote) async {
    await _firebaseService.updateDecision(decisionId, {
      'isSubmittedToVote': submitToVote,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    
    // Eğer oylamadan kaldırılıyorsa, tüm oyları sil
    if (!submitToVote) {
      await _firebaseService.deleteVotesForDecision(decisionId);
    }
    
    notifyListeners();
  }

  Future<void> loadVotes(String decisionId) async {
    _firebaseService.getVotesForDecision(decisionId).listen((votes) {
      _votes = votes;
      _updateStatistics(decisionId);
      notifyListeners();
    });
  }

  Future<void> _updateStatistics(String decisionId) async {
    _voteStatistics = await _firebaseService.getVoteStatistics(decisionId);
    notifyListeners();
  }

  Future<void> submitVote(String decisionId, String userId, String option,
      UserDemographics? demographics) async {
    final hasVoted = await _firebaseService.hasUserVoted(decisionId, userId);
    if (hasVoted) {
      throw Exception('Bu karar için zaten oy kullandınız');
    }

    final decisionRef = FirebaseFirestore.instance.collection('decisions').doc(decisionId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    
    final vote = Vote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      decisionRef: decisionRef,
      userRef: userRef,
      option: option,
      createdAt: DateTime.now(),
      demographics: demographics,
    );

    await _firebaseService.createVote(vote);
    await _updateStatistics(decisionId);
  }

  Future<void> removeVote(String decisionId, String userId) async {
    await _firebaseService.deleteUserVote(decisionId, userId);
    await _updateStatistics(decisionId);
  }
}

