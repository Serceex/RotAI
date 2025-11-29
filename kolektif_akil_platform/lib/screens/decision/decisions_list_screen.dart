import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/decision.dart';
import '../../services/firebase_service.dart';
import '../../providers/auth_provider.dart';
import 'vote_screen.dart';

class DecisionsListScreen extends StatefulWidget {
  const DecisionsListScreen({super.key});

  @override
  State<DecisionsListScreen> createState() => _DecisionsListScreenState();
}

class _DecisionsListScreenState extends State<DecisionsListScreen> {
  int _selectedTab = 0; // 0: Genel, 1: Benim oluşturduklarım

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Topluluk Oylaması',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
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
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
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
                      'Hata: ${snapshot.error}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final allDecisions = snapshot.data ?? [];
            
            // Filtreleme: Genel veya Benim oluşturduklarım
            final decisions = _selectedTab == 0
                ? allDecisions.where((d) => d.userId != currentUserId).toList()
                : allDecisions.where((d) => d.userId == currentUserId).toList();

            if (decisions.isEmpty) {
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
                        Icons.help_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _selectedTab == 0 ? 'Henüz soru yok' : 'Henüz soru oluşturmadınız',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedTab == 0 ? 'İlk soruyu siz sorun!' : 'İlk sorunuzu oluşturun!',
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
              itemCount: decisions.length,
              itemBuilder: (context, index) {
                final decision = decisions[index];
                
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
                
                return _ModernVoteCard(
                  decision: decision,
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VoteScreen(decision: decision),
                      ),
                    );
                  },
                  formatDate: _formatDate,
                );
              },
            );
          },
              ),
            ),
          ),
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Genel',
                      isSelected: _selectedTab == 0,
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Benim oluşturduklarım',
                      isSelected: _selectedTab == 1,
                      onTap: () {
                        setState(() {
                          _selectedTab = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          border: Border(
            top: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

// Modern Vote Card Widget with Animations
class _ModernVoteCard extends StatefulWidget {
  final Decision decision;
  final Map<String, Color> colorScheme;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  const _ModernVoteCard({
    required this.decision,
    required this.colorScheme,
    required this.onTap,
    required this.formatDate,
  });

  @override
  State<_ModernVoteCard> createState() => _ModernVoteCardState();
}

class _ModernVoteCardState extends State<_ModernVoteCard>
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
                                    const Spacer(),
                                    
                                    // Oy ver butonu
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            widget.colorScheme['primary']!,
                                            widget.colorScheme['secondary']!,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.how_to_vote_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Oy Ver',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 14,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ],
                                      ),
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
