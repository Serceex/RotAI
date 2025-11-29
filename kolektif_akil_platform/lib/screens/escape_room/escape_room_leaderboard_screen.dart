import 'package:flutter/material.dart';
import '../../models/room_session.dart';
import '../../services/escape_room_service.dart';

class EscapeRoomLeaderboardScreen extends StatefulWidget {
  const EscapeRoomLeaderboardScreen({super.key});

  @override
  State<EscapeRoomLeaderboardScreen> createState() =>
      _EscapeRoomLeaderboardScreenState();
}

class _EscapeRoomLeaderboardScreenState
    extends State<EscapeRoomLeaderboardScreen> {
  final EscapeRoomService _roomService = EscapeRoomService();
  List<RoomSession> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final leaderboard = await _roomService.getLeaderboard(limit: 50);
    setState(() {
      _leaderboard = leaderboard;
      _isLoading = false;
    });
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
        title: const Text('Liderlik Tablosu'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _leaderboard.length,
        itemBuilder: (context, index) {
          final session = _leaderboard[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text('Kullanıcı: ${session.userRef.id}'),
              subtitle: Text('Süre: ${session.timeSpent}s, İpucu: ${session.hintsUsed}'),
              trailing: Text(
                '${session.score}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

