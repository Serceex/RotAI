import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/achievements_config.dart';
import '../../services/achievement_service.dart';
import '../../providers/auth_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();
  Map<String, bool> _userAchievements = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    final achievements = await _achievementService.getUserAchievements(userId);
    setState(() {
      _userAchievements = achievements;
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

    final allAchievements = AchievementsConfig.getAllAchievements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarılar'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allAchievements.length,
        itemBuilder: (context, index) {
          final achievement = allAchievements[index];
          final isUnlocked = _userAchievements[achievement.id] == true;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isUnlocked
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: ListTile(
              leading: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 32),
              ),
              title: Text(achievement.title),
              subtitle: Text(achievement.description),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isUnlocked)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    const Icon(Icons.lock, color: Colors.grey),
                  Text('${achievement.points} puan'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

