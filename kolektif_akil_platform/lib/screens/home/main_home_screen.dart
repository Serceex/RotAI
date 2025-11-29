import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../models/decision.dart';
import '../../models/announcement.dart';
import '../../services/firebase_service.dart';
import '../../providers/auth_provider.dart';
import '../decision/vote_screen.dart';
import '../decision/decision_analysis_screen.dart';
import '../decision/decisions_list_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  Map<String, dynamic> _statistics = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final stats = await _calculateStatistics();
    if (mounted) {
      setState(() {
        _statistics = stats;
        _isLoadingStats = false;
      });
    }
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 1.2,
            duration: const Duration(milliseconds: 40),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  Future<Map<String, dynamic>> _calculateStatistics() async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Toplam karar sayısı
    final decisionsSnapshot = await firestore.collection('decisions').get();
    final totalDecisions = decisionsSnapshot.docs.length;

    // Toplam oy sayısı
    final votesSnapshot = await firestore.collection('votes').get();
    final totalVotes = votesSnapshot.docs.length;

    // Bugün verilen oy sayısı
    final todayVotes = votesSnapshot.docs.where((doc) {
      final voteData = doc.data();
      final createdAt = voteData['createdAt'];
      if (createdAt is String) {
        final voteDate = DateTime.parse(createdAt);
        return voteDate.isAfter(todayStart);
      }
      return false;
    }).length;

    // Toplam kullanıcı sayısı
    final usersSnapshot = await firestore.collection('users').get();
    final totalUsers = usersSnapshot.docs.length;

    return {
      'totalDecisions': totalDecisions,
      'totalVotes': totalVotes,
      'totalUsers': totalUsers,
      'todayVotes': todayVotes,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Rot',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: -0.5,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  TextSpan(
                    text: 'AI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: -0.5,
                      color: Color(0xFF96ADFC),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Yapay Zeka Destekli Analiz Rotası',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Hoş Geldin Kartı
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final currentUser = authProvider.currentUser;
                String userName = 'Kullanıcı';
                if (currentUser != null) {
                  if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
                    userName = currentUser.displayName!;
                  } else if (currentUser.email.isNotEmpty) {
                    userName = currentUser.email.split('@')[0];
                  }
                }
                final hour = DateTime.now().hour;
                String greeting;
                if (hour < 12) {
                  greeting = 'Günaydın';
                } else if (hour < 18) {
                  greeting = 'İyi günler';
                } else {
                  greeting = 'İyi akşamlar';
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9EB0C7), // Sabit renk - hem dark hem light mod için
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF9EB0C7).withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9EB0C7).withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        _AnimatedGreetingIcon(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting, $userName! 👋',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bugün hangi rotayı oluşturalım? 🗺️',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Hızlı Erişim Butonları
            Column(
              children: [
                _QuickActionCard(
                  icon: Icons.psychology_outlined,
                  title: 'Analiz Rotası',
                  color: const Color(0xFF9EB0C7), // Sabit renk - hem dark hem light mod için
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DecisionAnalysisScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _QuickActionCard(
                  icon: Icons.how_to_vote_outlined,
                  title: 'Oylamalar',
                  color: const Color(0xFF9EB0C7), // Sabit renk - hem dark hem light mod için
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DecisionsListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Bildirimler/Duyurular
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Bildirimler & Duyurular',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<Announcement>>(
              stream: _getAnnouncements(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return const SizedBox.shrink();
                }

                final announcements = snapshot.data ?? [];
                if (announcements.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Henüz duyuru yok',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: announcements.map((announcement) {
                    Color bgColor;
                    Color iconColor;
                    IconData icon;

                    switch (announcement.type) {
                      case 'success':
                        bgColor = Colors.green.shade50.withValues(alpha: 0.5);
                        iconColor = Colors.green.shade400;
                        icon = Icons.check_circle_outline;
                        break;
                      case 'warning':
                        bgColor = Colors.orange.shade50.withValues(alpha: 0.5);
                        iconColor = Colors.orange.shade400;
                        icon = Icons.warning_amber_outlined;
                        break;
                      case 'update':
                        bgColor = Colors.blue.shade50.withValues(alpha: 0.5);
                        iconColor = Colors.blue.shade400;
                        icon = Icons.system_update_outlined;
                        break;
                      default:
                        bgColor = Colors.blue.shade50.withValues(alpha: 0.5);
                        iconColor = Colors.blue.shade400;
                        icon = Icons.info_outline;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? bgColor.withValues(alpha: 0.1)
                            : bgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: iconColor.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                color: iconColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    announcement.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: iconColor,
                                          fontSize: 16,
                                          letterSpacing: -0.3,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    announcement.message,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 14,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _formatDate(announcement.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            // Popüler Sorular
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Popüler Sorular',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<Decision>>(
              stream: FirebaseService().getDecisions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Hata: ${snapshot.error}'),
                  );
                }

                final decisions = snapshot.data ?? [];
                if (decisions.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'Henüz soru yok',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ),
                    ),
                  );
                }

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getPopularQuestions(decisions),
                  builder: (context, popularSnapshot) {
                    if (popularSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final popularQuestions = popularSnapshot.data ?? [];
                    if (popularQuestions.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'Henüz oy verilen soru yok',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: popularQuestions.map((item) {
                        final decision = item['decision'] as Decision;
                        final voteCount = item['voteCount'] as int;
                        
                        // Tüm sorular için aynı renk
                        final gradientColors = [
                          const Color(0xFF9EB0C7),
                          const Color(0xFF8FA0B8),
                        ];
                        final colors = gradientColors;
                        // Beyaz metin kullan
                        final textColor = Colors.white;
                        final iconBgColor = Colors.white.withValues(alpha: 0.3);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colors[0].withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VoteScreen(decision: decision),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: colors,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: iconBgColor,
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.15),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.trending_up,
                                          color: textColor,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              decision.question,
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.3,
                                                height: 1.3,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: textColor.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.how_to_vote,
                                                        size: 14,
                                                        color: textColor.withValues(alpha: 0.95),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        '$voteCount oy',
                                                        style: TextStyle(
                                                          color: textColor.withValues(alpha: 0.95),
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: textColor.withValues(alpha: 0.85),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 100), // Alt panel için boşluk
                ],
              ),
            ),
          ),
          // İstatistik Ticker Panel - Alt menünün üstünde
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: _isLoadingStats
                ? const Center(child: CircularProgressIndicator())
                : _StatisticsTicker(
                    statistics: _statistics,
                    scrollController: _scrollController,
                  ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getPopularQuestions(
      List<Decision> decisions) async {
    final firestore = FirebaseFirestore.instance;
    final voteCounts = <String, int>{};

    // Tüm oyları çek ve her karar için oy sayısını hesapla
    for (final decision in decisions) {
      final decisionRef = firestore.collection('decisions').doc(decision.id);
      final votesSnapshot = await firestore
          .collection('votes')
          .where('decisionRef', isEqualTo: decisionRef)
          .get();
      voteCounts[decision.id] = votesSnapshot.docs.length;
    }

    // Oy sayısına göre sırala ve ilk 3'ü al
    final popularList = <Map<String, dynamic>>[];
    for (final decision in decisions) {
      final voteCount = voteCounts[decision.id] ?? 0;
      if (voteCount > 0) {
        popularList.add({
          'decision': decision,
          'voteCount': voteCount,
        });
      }
    }

    popularList.sort((a, b) => (b['voteCount'] as int).compareTo(a['voteCount'] as int));
    return popularList.take(3).toList();
  }

  Stream<List<Announcement>> _getAnnouncements() {
    return FirebaseFirestore.instance
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Announcement.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} dakika önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatisticsTicker extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final ScrollController scrollController;

  const _StatisticsTicker({
    required this.statistics,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatisticItem(
        icon: Icons.help_outline,
        label: 'Toplam Soru',
        value: '${statistics['totalDecisions'] ?? 0}',
        color: Colors.blue.shade400,
      ),
      _StatisticItem(
        icon: Icons.how_to_vote,
        label: 'Toplam Oy',
        value: '${statistics['totalVotes'] ?? 0}',
        color: Colors.green.shade400,
      ),
      _StatisticItem(
        icon: Icons.people_outline,
        label: 'Aktif Kullanıcı',
        value: '${statistics['totalUsers'] ?? 0}',
        color: Colors.orange.shade400,
      ),
      _StatisticItem(
        icon: Icons.today,
        label: 'Bugün Verilen Oy',
        value: '${statistics['todayVotes'] ?? 0}',
        color: Colors.purple.shade400,
      ),
    ];

    // İstatistikleri tekrarlayarak sürekli kaydırma efekti için
    final duplicatedItems = [...items, ...items, ...items];

    return ListView.builder(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: duplicatedItems.length,
      itemBuilder: (context, index) {
        final item = duplicatedItems[index % items.length];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: item.color,
                          fontSize: 17,
                          letterSpacing: -0.3,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatisticItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

// Hızlı Erişim Kartı Widget'ı
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: -0.3,
                      color: Color(0xFF212121), // Sabit koyu gri
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedGreetingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 24,
      )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.5))
          .then()
          .slideY(begin: 0, end: -0.1, duration: 1000.ms, curve: Curves.easeInOut)
          .then()
          .slideY(begin: -0.1, end: 0, duration: 1000.ms, curve: Curves.easeInOut),
    );
  }
}

