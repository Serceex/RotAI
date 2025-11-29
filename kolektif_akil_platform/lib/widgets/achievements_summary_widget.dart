import 'package:flutter/material.dart';
import '../utils/achievements_config.dart';

class AchievementsSummaryWidget extends StatelessWidget {
  final Map<String, bool> userAchievements;

  const AchievementsSummaryWidget({
    super.key,
    required this.userAchievements,
  });

  @override
  Widget build(BuildContext context) {
    final allAchievements = AchievementsConfig.getAllAchievements();
    final unlockedCount = userAchievements.values.where((v) => v).length;
    final totalPoints = allAchievements
        .where((a) => userAchievements[a.id] == true)
        .fold(0, (sum, a) => sum + a.points);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Başarılar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$unlockedCount/${allAchievements.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Açılan'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$totalPoints',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const Text('Toplam Puan'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

