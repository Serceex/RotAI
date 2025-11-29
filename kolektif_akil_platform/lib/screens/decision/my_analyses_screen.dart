import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/decision.dart';
import '../../services/firebase_service.dart';
import 'decision_analysis_screen.dart';

class MyAnalysesScreen extends StatelessWidget {
  const MyAnalysesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final firebaseService = FirebaseService();

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analizlerim'),
        ),
        body: const Center(
          child: Text('Giriş yapmanız gerekiyor'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analizlerim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: StreamBuilder<List<Decision>>(
          stream: firebaseService.getDecisions(),
          builder: (context, decisionSnapshot) {
            if (decisionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (decisionSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hata: ${decisionSnapshot.error}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Sadece kullanıcının kendi analizlerini filtrele
            final allDecisions = decisionSnapshot.data ?? [];
            final myDecisions = allDecisions
                .where((decision) => decision.userId == currentUser.id)
                .toList();

            if (myDecisions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Henüz analiz yapmadınız',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni bir analiz rotası oluşturarak başlayın',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: myDecisions.length,
              itemBuilder: (context, index) {
                final decision = myDecisions[index];
                
                // Ana temaya uyumlu renk tonları - sadece gri-mavi tonları
                final colorVariations = [
                  {
                    'primary': const Color(0xFF8C9CB1),
                    'secondary': const Color(0xFF9EB0C7),
                    'light': const Color(0xFFE8EDF3),
                    'medium': const Color(0xFFD1DAE5),
                  },
                  {
                    'primary': const Color(0xFF7A8A9F),
                    'secondary': const Color(0xFF8C9CB1),
                    'light': const Color(0xFFE0E7EF),
                    'medium': const Color(0xFFC5D0DD),
                  },
                  {
                    'primary': const Color(0xFF9EB0C7),
                    'secondary': const Color(0xFFAFBFD3),
                    'light': const Color(0xFFF0F4F8),
                    'medium': const Color(0xFFDDE5ED),
                  },
                ];
                
                final colorScheme = colorVariations[index % colorVariations.length];
                
                return _ModernAnalysisCard(
                  decision: decision,
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DecisionResultScreen(decision: decision),
                      ),
                    );
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red.shade600,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Analizi Sil'),
                          ],
                        ),
                        content: const Text(
                          'Bu analizi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('İptal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Sil'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        if (decision.id.isEmpty) {
                          throw Exception('Analiz ID\'si bulunamadı');
                        }
                        
                        await firebaseService.deleteDecision(decision.id);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Analiz başarıyla silindi'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Silme hatası: ${e.toString()}'),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  formatDate: _formatDate,
                );
              },
            );
          },
        ),
      ),
    );
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

// Modern Analysis Card Widget with Animations
class _ModernAnalysisCard extends StatefulWidget {
  final Decision decision;
  final Map<String, Color> colorScheme;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDate;

  const _ModernAnalysisCard({
    required this.decision,
    required this.colorScheme,
    required this.onTap,
    required this.onDelete,
    required this.formatDate,
  });

  @override
  State<_ModernAnalysisCard> createState() => _ModernAnalysisCardState();
}

class _ModernAnalysisCardState extends State<_ModernAnalysisCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _elevationAnimation = Tween<double>(begin: 8.0, end: 16.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: MouseRegion(
              onEnter: (_) => _onHoverChanged(true),
              onExit: (_) => _onHoverChanged(false),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: _elevationAnimation.value,
                          offset: Offset(0, _elevationAnimation.value / 3),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Sol tarafta renkli dikey çubuk
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isHovered ? 6 : 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                widget.colorScheme['primary']!,
                                widget.colorScheme['secondary']!,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                        
                        // İçerik
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Soru metni
                                Text(
                                  widget.decision.question,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                        fontSize: 16,
                                        color: Colors.grey[900],
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 14),
                                
                                // Alt bilgiler
                                Row(
                                  children: [
                                    // Zaman bilgisi
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.formatDate(widget.decision.createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Durum rozeti
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: widget.decision.isSubmittedToVote
                                            ? Colors.green.shade50
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            widget.decision.isSubmittedToVote
                                                ? Icons.check_circle
                                                : Icons.edit_outlined,
                                            size: 12,
                                            color: widget.decision.isSubmittedToVote
                                                ? Colors.green.shade700
                                                : Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.decision.isSubmittedToVote
                                                ? 'Oylamada'
                                                : 'Taslak',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: widget.decision.isSubmittedToVote
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    
                                    // Sil butonu
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: widget.onDelete,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.grey.shade400,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    
                                    // Ok ikonu
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: widget.colorScheme['primary']!.withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

