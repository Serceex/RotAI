import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/escape_room.dart';
import '../../models/room_session.dart';
import '../../models/decision.dart';
import '../../services/escape_room_service.dart';
import '../../services/room_hint_service.dart';
import '../../services/room_question_service.dart';
import '../../services/gemini_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import 'escape_room_result_screen.dart';

class EscapeRoomPlayScreen extends StatefulWidget {
  final EscapeRoom room;

  const EscapeRoomPlayScreen({super.key, required this.room});

  @override
  State<EscapeRoomPlayScreen> createState() => _EscapeRoomPlayScreenState();
}

class _EscapeRoomPlayScreenState extends State<EscapeRoomPlayScreen> {
  final EscapeRoomService _roomService = EscapeRoomService();
  final RoomHintService _hintService = RoomHintService(
    geminiService: GeminiService(apiKey: ApiConfig.geminiApiKey),
  );

  Timer? _timer;
  int _timeRemaining = 0;
  int _hintsUsed = 0;
  List<String> _hints = [];
  String? _selectedOption;
  RoomSession? _session;
  Decision? _decision;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.room.difficulty.timeLimit;
    _loadRoom();
    _startTimer();
  }

  Future<void> _loadRoom() async {
    setState(() => _isLoading = true);

    try {
      // Eğer decisionId varsa, decision'ı getir
      if (widget.room.decisionId != null && widget.room.decisionId!.isNotEmpty) {
        // Decision'ı getir (FirebaseService kullanılabilir)
        // Şimdilik boş bırakıyoruz
      } else {
        // AI ile hazır soru oluştur
        final questionService = RoomQuestionService(
          geminiService: GeminiService(apiKey: ApiConfig.geminiApiKey),
        );
        final decision = await questionService.generateQuestionForCategory(
          widget.room.category ?? 'other',
          widget.room.difficulty,
        );
        _decision = decision;
      }

      // Session oluştur
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
        _session = RoomSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          roomId: widget.room.id,
          userRef: userRef,
          startedAt: DateTime.now(),
        );
        await _roomService.createSession(_session!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          } else {
            _timer?.cancel();
            _submitAnswer(null); // Süre doldu
          }
        });
      }
    });
  }

  Future<void> _getHint() async {
    if (_hintsUsed >= widget.room.difficulty.hintCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm ipuçlarını kullandınız!')),
      );
      return;
    }

    try {
      final hint = await _hintService.generateHint(
        widget.room,
        _hintsUsed + 1,
        _hints,
      );
      setState(() {
        _hints.add(hint);
        _hintsUsed++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İpucu alınamadı: $e')),
        );
      }
    }
  }

  Future<void> _submitAnswer(String? option) async {
    _timer?.cancel();

    if (_session == null) return;

    final timeSpent = widget.room.difficulty.timeLimit - _timeRemaining;
    final isCorrect = option != null && _decision != null
        ? _decision!.isCorrectAnswer(option)
        : false;

    // Skor hesapla
    int score = 0;
    if (isCorrect) {
      score = widget.room.difficulty.baseScore;
      // Zaman bonusu
      final timeBonus = (_timeRemaining * 2).clamp(0, 100);
      score += timeBonus;
      // İpucu cezası
      final hintPenalty = _hintsUsed * 10;
      score = (score - hintPenalty).clamp(0, double.infinity).toInt();
    }

    // Session'ı güncelle
    await _roomService.updateSession(_session!.id, {
      'selectedOption': option,
      'isCompleted': true,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'hintsUsed': _hintsUsed,
      'score': score,
      'completedAt': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EscapeRoomResultScreen(
            room: widget.room,
            session: _session!,
            isCorrect: isCorrect,
            score: score,
            timeSpent: timeSpent,
            hintsUsed: _hintsUsed,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.title),
      ),
      body: Column(
        children: [
          // Timer ve ipucu bilgisi
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Kalan Süre'),
                    Text(
                      '${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('İpucu'),
                    Text(
                      '${_hintsUsed}/${widget.room.difficulty.hintCount}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Soru ve seçenekler
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.room.question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _OptionButton(
                    option: 'A',
                    text: widget.room.optionA,
                    isSelected: _selectedOption == 'A',
                    onTap: () => setState(() => _selectedOption = 'A'),
                  ),
                  const SizedBox(height: 16),
                  _OptionButton(
                    option: 'B',
                    text: widget.room.optionB,
                    isSelected: _selectedOption == 'B',
                    onTap: () => setState(() => _selectedOption = 'B'),
                  ),
                  const SizedBox(height: 24),
                  // İpucu butonu
                  ElevatedButton.icon(
                    onPressed: _getHint,
                    icon: const Icon(Icons.lightbulb),
                    label: const Text('İpucu Al'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  // İpuçları göster
                  if (_hints.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'İpuçları:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ..._hints.map((hint) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.lightbulb_outline),
                            title: Text(hint),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
          // Cevap gönder butonu
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selectedOption != null
                  ? () => _submitAnswer(_selectedOption)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Cevabı Gönder'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String option;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

