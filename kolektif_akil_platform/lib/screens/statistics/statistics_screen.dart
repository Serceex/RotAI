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
                          icon: Icons.help_outline,
                          label: 'Toplam Karar',
                          value: '${stats['totalDecisions'] ?? 0}',
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
                // En Popüler Kararlar
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'En Popüler Kararlar',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        if ((stats['popularDecisions'] as List?)?.isEmpty ?? true)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Henüz oy verilen karar yok',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...((stats['popularDecisions'] as List?) ?? []).map<Widget>((decision) {
                            final decisionData = decision as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          decisionData['question'] ?? '',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${decisionData['voteCount'] ?? 0} oy',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.trending_up,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            );
                          }),
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

    // En popüler kararlar (en çok oy alan 5 karar)
    final decisionVoteCounts = <String, int>{};
    for (var voteDoc in votesSnapshot.docs) {
      // Get decisionId from decisionRef DocumentReference
      final voteData = voteDoc.data();
      final decisionRef = voteData['decisionRef'] as DocumentReference?;
      final decisionId = decisionRef?.id;
      if (decisionId != null) {
        decisionVoteCounts[decisionId] =
            (decisionVoteCounts[decisionId] ?? 0) + 1;
      }
    }

    final popularDecisions = <Map<String, dynamic>>[];
    for (var decisionDoc in decisionsSnapshot.docs) {
      final decisionId = decisionDoc.id;
      final voteCount = decisionVoteCounts[decisionId] ?? 0;
      if (voteCount > 0) {
        final decisionData = decisionDoc.data();
        popularDecisions.add({
          'id': decisionId,
          'question': decisionData['question'] ?? '',
          'voteCount': voteCount,
        });
      }
    }

    // Oy sayısına göre sırala
    popularDecisions.sort((a, b) => (b['voteCount'] as int).compareTo(a['voteCount'] as int));

    // İlk 5'i al
    final top5Decisions = popularDecisions.take(5).toList();

    return {
      'totalDecisions': totalDecisions,
      'totalVotes': totalVotes,
      'totalUsers': totalUsers,
      'totalAnalyses': totalAnalyses,
      'popularDecisions': top5Decisions,
    };
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

