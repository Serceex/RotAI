import 'package:flutter/material.dart';
import '../../models/escape_room.dart';
import '../../models/room_session.dart';

class EscapeRoomResultScreen extends StatelessWidget {
  final EscapeRoom room;
  final RoomSession session;
  final bool isCorrect;
  final int score;
  final int timeSpent;
  final int hintsUsed;

  const EscapeRoomResultScreen({
    super.key,
    required this.room,
    required this.session,
    required this.isCorrect,
    required this.score,
    required this.timeSpent,
    required this.hintsUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonuç'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sonuç ikonu
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            // Sonuç mesajı
            Text(
              isCorrect ? 'Tebrikler! Doğru Cevap!' : 'Yanlış Cevap',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Skor kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Skor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Detaylar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ResultRow(
                      label: 'Geçen Süre',
                      value: '${timeSpent ~/ 60}:${(timeSpent % 60).toString().padLeft(2, '0')}',
                    ),
                    const Divider(),
                    _ResultRow(
                      label: 'Kullanılan İpucu',
                      value: '$hintsUsed/${room.difficulty.hintCount}',
                    ),
                    const Divider(),
                    _ResultRow(
                      label: 'Zorluk',
                      value: room.difficulty.label,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Butonlar
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

