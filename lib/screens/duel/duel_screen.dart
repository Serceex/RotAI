import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/decision.dart';
import '../../services/firebase_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/decision_provider.dart';

class DuelScreen extends StatefulWidget {
  const DuelScreen({super.key});

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final PageController _pageController = PageController();
  List<Decision> _shuffledDecisions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  final Map<String, bool> _hasVotedMap = {};

  @override
  void initState() {
    super.initState();
    _loadDecisions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDecisions() async {
    try {
      final stream = _firebaseService.getDecisionsSubmittedToVote();
      await for (final decisions in stream) {
        if (mounted) {
          setState(() {
            _shuffledDecisions = List.from(decisions)..shuffle(Random());
          });
          await _checkVotes();
        }
        break; // İlk yüklemeden sonra stream'i dinlemeyi bırak
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _checkVotes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final Map<String, bool> votedMap = {};
    for (var decision in _shuffledDecisions) {
      final hasVoted = await _firebaseService.hasUserVoted(decision.id, user.id);
      votedMap[decision.id] = hasVoted;
    }

    if (mounted) {
      setState(() {
        _hasVotedMap.addAll(votedMap);
        // Sadece oy verilmemiş kararları göster
        _shuffledDecisions = _shuffledDecisions
            .where((decision) => !(votedMap[decision.id] ?? false))
            .toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitVote(String decisionId, String option) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oy vermek için giriş yapmanız gerekiyor')),
      );
      return;
    }

    try {
      final decisionProvider = Provider.of<DecisionProvider>(context, listen: false);
      await decisionProvider.submitVote(decisionId, user.id, option, null);
      
      // Oy verilen kararı listeden kaldır
      setState(() {
        _hasVotedMap[decisionId] = true;
        final removedIndex = _shuffledDecisions.indexWhere((d) => d.id == decisionId);
        if (removedIndex != -1) {
          _shuffledDecisions.removeAt(removedIndex);
          // Eğer kaldırılan kart mevcut index'teki kart ise veya son kart ise
          if (removedIndex <= _currentIndex) {
            if (_currentIndex > 0) {
              _currentIndex--;
            } else {
              _currentIndex = 0;
            }
          }
        }
      });

      // Bir sonraki karta geç (eğer varsa)
      if (_shuffledDecisions.isEmpty) {
        // Tüm kararlara oy verildi - boş durum ekranı gösterilecek
        if (mounted) {
          setState(() {
            _currentIndex = 0;
          });
        }
      } else {
        // Eğer mevcut index geçerli değilse, düzelt
        if (_currentIndex >= _shuffledDecisions.length) {
          // Liste boş değil ama index geçersiz - son karta git veya boş durum göster
          if (_shuffledDecisions.isEmpty) {
            setState(() {
              _currentIndex = 0;
            });
          } else {
            setState(() {
              _currentIndex = _shuffledDecisions.length - 1;
            });
            _pageController.jumpToPage(_currentIndex);
          }
        } else if (_currentIndex < _shuffledDecisions.length - 1) {
          // Bir sonraki karta geç - hızlı geçiş
          setState(() {
            _currentIndex++;
          });
          _pageController.nextPage(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        } else {
          // Son kartta kaldıysa, index'i güncelle
          // Eğer bu son kart ise ve oy verildiyse, boş durum gösterilecek
          setState(() {
            if (_shuffledDecisions.isEmpty) {
              _currentIndex = 0;
            } else {
              _currentIndex = _shuffledDecisions.length - 1;
            }
          });
          if (_shuffledDecisions.isNotEmpty) {
            _pageController.jumpToPage(_currentIndex);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    }
  }

  void _skipDecision() {
    // Pas geçilen kartı listeden kaldır
    if (_currentIndex < _shuffledDecisions.length) {
      setState(() {
        _shuffledDecisions.removeAt(_currentIndex);
        // Eğer kaldırılan kart son kart ise, index'i düzelt
        if (_currentIndex >= _shuffledDecisions.length && _shuffledDecisions.isNotEmpty) {
          _currentIndex = _shuffledDecisions.length - 1;
        } else if (_currentIndex >= _shuffledDecisions.length) {
          _currentIndex = 0;
        }
      });

      // Bir sonraki karta geç (eğer varsa)
      if (_shuffledDecisions.isEmpty) {
        // Tüm kartlar pas geçildi - boş durum ekranı gösterilecek
        if (mounted) {
          setState(() {
            _currentIndex = 0;
          });
        }
      } else if (_currentIndex < _shuffledDecisions.length) {
        // Hala kartlar var, mevcut index'teki kartı göster
        _pageController.jumpToPage(_currentIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Duello'),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_shuffledDecisions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Duello'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Tüm kararlara oy verdiniz!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yeni kararlar eklendiğinde burada görünecek',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duello'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Arka plan - koyu mavi
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
            ),
          ),
          // PageView ile kartlar - swipe devre dışı
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Kartlar arası geçişi engelle
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _shuffledDecisions.length,
            itemBuilder: (context, index) {
              if (index >= _shuffledDecisions.length) {
                return const SizedBox.shrink();
              }
              final decision = _shuffledDecisions[index];
              
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: _DuelCard(
                  decision: decision,
                  hasVoted: false, // Artık sadece oy verilmemiş kararlar gösteriliyor
                  onSwipeLeft: () => _submitVote(decision.id, 'B'),
                  onSwipeRight: () => _submitVote(decision.id, 'A'),
                  onSwipeUp: _skipDecision,
                ),
              );
            },
          ),
          // Alt sayfa göstergesi
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_shuffledDecisions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuelCard extends StatefulWidget {
  final Decision decision;
  final bool hasVoted;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;

  const _DuelCard({
    required this.decision,
    required this.hasVoted,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
  });

  @override
  State<_DuelCard> createState() => _DuelCardState();
}

class _DuelCardState extends State<_DuelCard> with SingleTickerProviderStateMixin {
  double _dragX = 0;
  double _dragY = 0;
  bool _isDismissing = false;
  String? _dismissDirection; // 'up', 'left', 'right'
  late AnimationController _dismissController;
  late Animation<double> _dismissAnimation;

  IconData _getCategoryIcon(String? category) {
    if (category == null || category.isEmpty) {
      return Icons.category;
    }
    
    final categoryLower = category.toLowerCase().trim();
    
    // İngilizce ve Türkçe kategori isimlerini kontrol et
    if (categoryLower == 'career' || categoryLower == 'kariyer') {
      return Icons.work;
    } else if (categoryLower == 'education' || categoryLower == 'eğitim') {
      return Icons.school;
    } else if (categoryLower == 'finance' || categoryLower == 'finans') {
      return Icons.attach_money;
    } else if (categoryLower == 'relationships' || categoryLower == 'ilişkiler') {
      return Icons.favorite;
    } else if (categoryLower == 'health' || categoryLower == 'sağlık') {
      return Icons.health_and_safety;
    } else if (categoryLower == 'technology' || categoryLower == 'tekno' || categoryLower == 'teknoloji') {
      return Icons.computer;
    } else if (categoryLower == 'travel' || categoryLower == 'seyahat') {
      return Icons.flight;
    } else if (categoryLower == 'other' || categoryLower == 'diğer') {
      return Icons.more_horiz;
    } else if (categoryLower == 'general' || categoryLower == 'genel') {
      return Icons.category;
    }
    
    // Türkçe kategori isimlerini kontrol et
    switch (category) {
      case 'Kariyer':
        return Icons.work;
      case 'Eğitim':
        return Icons.school;
      case 'Finans':
        return Icons.attach_money;
      case 'İlişkiler':
        return Icons.favorite;
      case 'Sağlık':
        return Icons.health_and_safety;
      case 'Teknoloji':
        return Icons.computer;
      case 'Seyahat':
        return Icons.flight;
      case 'Diğer':
        return Icons.more_horiz;
      case 'Genel':
        return Icons.category;
      default:
        return Icons.category;
    }
  }
  
  String _getCategoryName(String? category) {
    if (category == null || category.isEmpty) {
      return 'Genel';
    }
    
    // Geçerli kategoriler listesi
    final validCategories = [
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
    
    // İngilizce kategori isimlerini Türkçe'ye çevir
    final categoryLower = category.toLowerCase().trim();
    
    // İngilizce-Türkçe eşleştirme
    final categoryMap = {
      'general': 'Genel',
      'career': 'Kariyer',
      'education': 'Eğitim',
      'finance': 'Finans',
      'relationships': 'İlişkiler',
      'health': 'Sağlık',
      'technology': 'Teknoloji',
      'travel': 'Seyahat',
      'other': 'Diğer',
    };
    
    // İngilizce kategori ise Türkçe'ye çevir
    if (categoryMap.containsKey(categoryLower)) {
      return categoryMap[categoryLower]!;
    }
    
    // Türkçe kategori ise ve geçerliyse olduğu gibi döndür
    if (validCategories.contains(category)) {
      return category;
    }
    
    // Geçersiz kategori ise "Genel" döndür
    return 'Genel';
  }

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _dismissAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  void _dismissUp() {
    setState(() {
      _isDismissing = true;
      _dismissDirection = 'up';
    });
    // Hemen callback'i çağır, animasyon devam ederken işlem yapılsın
    widget.onSwipeUp();
    _dismissController.forward();
  }

  void _dismissLeft() {
    setState(() {
      _isDismissing = true;
      _dismissDirection = 'left';
    });
    // Hemen callback'i çağır, animasyon devam ederken işlem yapılsın
    widget.onSwipeLeft();
    _dismissController.forward();
  }

  void _dismissRight() {
    setState(() {
      _isDismissing = true;
      _dismissDirection = 'right';
    });
    // Hemen callback'i çağır, animasyon devam ederken işlem yapılsın
    widget.onSwipeRight();
    _dismissController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth - 48;
    final cardHeight = screenHeight - 200;

    return GestureDetector(
      onPanStart: (_) {},
      onPanUpdate: (details) {
        setState(() {
          _dragX += details.delta.dx;
          _dragY += details.delta.dy;
        });
      },
      onPanEnd: (details) {
        final threshold = cardWidth * 0.2; // Daha hassas threshold - daha erken tetikleme
        final verticalThreshold = cardHeight * 0.12; // Daha hassas yukarı threshold

        // Önce yukarı kaydırmayı kontrol et (pas geç)
        if (_dragY < -verticalThreshold && _dragX.abs() < threshold) {
          // Yukarı kaydırma (pas) - oy kullanmadan geç - animasyonlu
          _dismissUp();
          return;
        } else if (_dragX.abs() > threshold) {
          // Sağa veya sola kaydırma - oy kullan - animasyonlu
          if (_dragX > 0) {
            // Sağa kaydırma - Seçenek 1 (A)
            _dismissRight();
          } else {
            // Sola kaydırma - Seçenek 2 (B)
            _dismissLeft();
          }
          return;
        } else {
          // Yeterli kaydırma yok, kartı geri getir
          setState(() {
            _dragX = 0;
            _dragY = 0;
          });
        }
      },
      child: AnimatedBuilder(
        animation: _dismissAnimation,
        builder: (context, child) {
          // Drag pozisyonuna göre rotasyon ve offset
          double rotation = _dragX / cardWidth * 0.1;
          double opacity = 1.0;
          double translateX = _dragX;
          double translateY = _dragY;
          
          if (_isDismissing) {
            // Dismiss animasyonu - yönüne göre
            if (_dismissDirection == 'up') {
              translateY = -_dismissAnimation.value * screenHeight;
              opacity = 1.0 - _dismissAnimation.value;
            } else if (_dismissDirection == 'left') {
              translateX = -_dismissAnimation.value * screenWidth;
              opacity = 1.0 - _dismissAnimation.value;
            } else if (_dismissDirection == 'right') {
              translateX = _dismissAnimation.value * screenWidth;
              opacity = 1.0 - _dismissAnimation.value;
            }
          } else {
            // Normal drag durumu
            opacity = 1.0 - (_dragX.abs() / cardWidth * 0.5).clamp(0.0, 0.5);
            // Yukarı kaydırma sırasında görsel geri bildirim
            if (_dragY < 0) {
              opacity = 1.0 - (_dragY.abs() / cardHeight * 0.3).clamp(0.0, 0.3);
            }
          }
          
          return Transform.translate(
            offset: Offset(translateX, translateY),
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
              child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Kategori başlığı
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(widget.decision.category),
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getCategoryName(widget.decision.category).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Soru
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Center(
                        child: Text(
                          widget.decision.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Seçenekler
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Seçenek A (Sağa kaydır)
                        GestureDetector(
                          onTap: widget.hasVoted ? null : widget.onSwipeRight,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    widget.decision.optionA ?? 'Seçenek A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // VS göstergesi
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'vs',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Seçenek B (Sola kaydır)
                        GestureDetector(
                          onTap: widget.hasVoted ? null : widget.onSwipeLeft,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.orange[600],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    widget.decision.optionB ?? 'Seçenek B',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.hasVoted) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Bu karara oy verdiniz',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
              ),
            ),
          );
        },
      ),
    );
  }
}

