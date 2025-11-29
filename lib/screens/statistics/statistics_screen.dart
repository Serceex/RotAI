import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _getStatisticsStream(firebaseService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          }

          final stats = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Genel İstatistikler
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genel İstatistikler',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _StatisticItem(
                          icon: Icons.how_to_vote_outlined,
                          label: 'Oylamadaki Analiz',
                          value: '${stats['submittedToVote'] ?? 0}',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _StatisticItem(
                          icon: Icons.how_to_vote,
                          label: 'Toplam Oy',
                          value: '${stats['totalVotes'] ?? 0}',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _StatisticItem(
                          icon: Icons.people_outline,
                          label: 'Toplam Kullanıcı',
                          value: '${stats['totalUsers'] ?? 0}',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _StatisticItem(
                          icon: Icons.analytics_outlined,
                          label: 'Toplam Analiz',
                          value: '${stats['totalAnalyses'] ?? 0}',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Kategori Bazlı İstatistikler
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kategori Bazlı İstatistikler',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if ((stats['categoryStats'] as Map?)?.isEmpty ?? true)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Henüz kategori bazlı veri yok',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ..._buildCategoryStats(context, stats['categoryStats'] as Map<String, dynamic>? ?? {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Stream<Map<String, dynamic>> _getStatisticsStream(
      FirebaseService firebaseService) async* {
    while (true) {
      try {
        final stats = await _calculateStatistics(firebaseService);
        yield stats;
        await Future.delayed(const Duration(seconds: 5)); // Her 5 saniyede bir güncelle
      } catch (e) {
        yield {'error': e.toString()};
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  Future<Map<String, dynamic>> _calculateStatistics(
      FirebaseService firebaseService) async {
    final firestore = FirebaseFirestore.instance;

    // Toplam karar sayısı
    final decisionsSnapshot = await firestore.collection('decisions').get();
    final totalDecisions = decisionsSnapshot.docs.length;

    // Oylamaya sunulan analiz sayısı (isSubmittedToVote: true olan kararlar)
    final submittedToVote = decisionsSnapshot.docs
        .where((doc) => doc.data()['isSubmittedToVote'] == true)
        .length;

    // Toplam oy sayısı
    final votesSnapshot = await firestore.collection('votes').get();
    final totalVotes = votesSnapshot.docs.length;

    // Toplam kullanıcı sayısı
    final usersSnapshot = await firestore.collection('users').get();
    final totalUsers = usersSnapshot.docs.length;

    // Toplam analiz sayısı (decisionTree'i olan kararlar)
    final totalAnalyses = decisionsSnapshot.docs
        .where((doc) => doc.data()['decisionTree'] != null)
        .length;

    // Kategori bazlı istatistikler
    final categoryStats = <String, Map<String, dynamic>>{};
    
    // Kategori tanımları
    final categories = [
      'Genel',
      'Kariyer',
      'Eğitim',
      'Finans',
      'İlişkiler',
      'Sağlık',
      'Teknoloji',
      'Seyahat',
      'Diğer',
    ];
    
    // Her kategori için istatistik hesapla
    for (final category in categories) {
      final categoryDecisions = decisionsSnapshot.docs.where((doc) {
        final docCategory = doc.data()['category'] as String?;
        final normalizedCategory = (docCategory == null || docCategory.isEmpty) ? 'Genel' : docCategory;
        return normalizedCategory == category;
      }).toList();
      
      final categoryDecisionIds = categoryDecisions.map((doc) => doc.id).toSet();
      final categoryVotes = votesSnapshot.docs.where((voteDoc) {
        final voteData = voteDoc.data();
        final decisionRef = voteData['decisionRef'] as DocumentReference?;
        final decisionId = decisionRef?.id;
        return decisionId != null && categoryDecisionIds.contains(decisionId);
      }).length;
      
      // Oylamaya sunulan analiz sayısı (isSubmittedToVote: true olan kararlar)
      final categorySubmittedToVote = categoryDecisions
          .where((doc) => doc.data()['isSubmittedToVote'] == true)
          .length;
      
      categoryStats[category] = {
        'decisions': categoryDecisions.length,
        'submittedToVote': categorySubmittedToVote,
        'votes': categoryVotes,
        'analyses': categoryDecisions.where((doc) => doc.data()['decisionTree'] != null).length,
      };
    }

    return {
      'totalDecisions': totalDecisions,
      'submittedToVote': submittedToVote,
      'totalVotes': totalVotes,
      'totalUsers': totalUsers,
      'totalAnalyses': totalAnalyses,
      'categoryStats': categoryStats,
    };
  }

  List<Widget> _buildCategoryStats(BuildContext context, Map<String, dynamic> categoryStats) {
    final categories = [
      {'name': 'Genel', 'icon': Icons.category, 'color': Colors.grey},
      {'name': 'Kariyer', 'icon': Icons.work, 'color': Colors.blue},
      {'name': 'Eğitim', 'icon': Icons.school, 'color': Colors.green},
      {'name': 'Finans', 'icon': Icons.attach_money, 'color': Colors.orange},
      {'name': 'İlişkiler', 'icon': Icons.favorite, 'color': Colors.pink},
      {'name': 'Sağlık', 'icon': Icons.health_and_safety, 'color': Colors.red},
      {'name': 'Teknoloji', 'icon': Icons.computer, 'color': Colors.purple},
      {'name': 'Seyahat', 'icon': Icons.flight, 'color': Colors.teal},
      {'name': 'Diğer', 'icon': Icons.more_horiz, 'color': Colors.brown},
    ];

    return categories.map<Widget>((categoryInfo) {
      final categoryName = categoryInfo['name'] as String;
      final categoryIcon = categoryInfo['icon'] as IconData;
      final categoryColor = categoryInfo['color'] as Color;
      
      final stats = categoryStats[categoryName] as Map<String, dynamic>? ?? {};
      final submittedToVote = stats['submittedToVote'] ?? 0;
      final votes = stats['votes'] ?? 0;
      final analyses = stats['analyses'] ?? 0;
      
      // Toplam oylamaya sunulan analiz sayısını hesapla (yüzde için)
      final totalSubmittedToVote = categoryStats.values
          .map((s) => (s as Map)['submittedToVote'] ?? 0)
          .fold<int>(0, (sum, count) => sum + (count as int));
      
      final percentage = totalSubmittedToVote > 0 ? (submittedToVote / totalSubmittedToVote * 100) : 0.0;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: categoryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CategoryStatItem(
                    icon: Icons.how_to_vote_outlined,
                    label: 'Oylamadaki\nAnaliz',
                    value: '$submittedToVote',
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CategoryStatItem(
                    icon: Icons.how_to_vote,
                    label: 'Oy',
                    value: '$votes',
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CategoryStatItem(
                    icon: Icons.analytics_outlined,
                    label: 'Analiz',
                    value: '$analyses',
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _CategoryStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CategoryStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 18,
              ),
        ),
      ],
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

