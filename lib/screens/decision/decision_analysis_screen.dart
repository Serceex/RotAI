import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/decision_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/decision.dart';
import '../../services/firebase_service.dart';
import 'decision_tree_widget.dart';

class DecisionAnalysisScreen extends StatefulWidget {
  const DecisionAnalysisScreen({super.key});

  @override
  State<DecisionAnalysisScreen> createState() => _DecisionAnalysisScreenState();
}

class _DecisionAnalysisScreenState extends State<DecisionAnalysisScreen> {
  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  String _selectedCategory = 'Genel';
  bool _isAnalyzing = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Genel', 'icon': Icons.category},
    {'name': 'Kariyer', 'icon': Icons.work},
    {'name': 'Eğitim', 'icon': Icons.school},
    {'name': 'Finans', 'icon': Icons.attach_money},
    {'name': 'İlişkiler', 'icon': Icons.favorite},
    {'name': 'Sağlık', 'icon': Icons.health_and_safety},
    {'name': 'Teknoloji', 'icon': Icons.computer},
    {'name': 'Seyahat', 'icon': Icons.flight},
    {'name': 'Diğer', 'icon': Icons.more_horiz},
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    super.dispose();
  }

  Future<void> _analyzeDecision() async {
    // Validasyon
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir karar sorusu girin')),
      );
      return;
    }

    if (_optionAController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen Seçenek 1\'i girin')),
      );
      return;
    }

    if (_optionBController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen Seçenek 2\'yi girin')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final decisionProvider =
          Provider.of<DecisionProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Kullanıcı giriş yapmış olmalı
      if (authProvider.currentUser == null) {
        throw Exception('Analiz rotası için giriş yapmanız gerekiyor');
      }

      final userId = authProvider.currentUser!.id;
      final decision = await decisionProvider.analyzeDecision(
        _questionController.text.trim(),
        optionA: _optionAController.text.trim(),
        optionB: _optionBController.text.trim(),
        category: _selectedCategory,
        userId: userId,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DecisionResultScreen(decision: decision),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analiz hatası: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Rotası'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Karar Giriş Kartı
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Rotanızı Belirleyin',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Soru Alanı
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _questionController,
                          maxLines: 4,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Karar Sorusu *',
                            hintText:
                                'Örn: Yeni bir iş teklifini kabul edip büyük şehre mi taşınmalıyım, yoksa mevcut işimde kalarak master mı yapmalıyım?',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Seçenek 1
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _optionAController,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Seçenek 1 *',
                            hintText: 'İlk seçeneğinizi yazın',
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green[400]!,
                                    Colors.green[600]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Seçenek 2
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _optionBController,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Seçenek 2 *',
                            hintText: 'İkinci seçeneğinizi yazın',
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange[400]!,
                                    Colors.orange[600]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Kategori Seçimi
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori *',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 50,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final categoryName = category['name'] as String;
                                final categoryIcon = category['icon'] as IconData;
                                final isSelected = _selectedCategory == categoryName;
                                return ChoiceChip(
                                  avatar: Icon(
                                    categoryIcon,
                                    size: 18,
                                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                                  ),
                                  label: Text(categoryName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = categoryName;
                                    });
                                  },
                                  selectedColor: Theme.of(context).colorScheme.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  side: isSelected
                                      ? BorderSide.none
                                      : BorderSide(
                                          color: Colors.grey.withValues(alpha: 0.3),
                                        ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isAnalyzing ? null : _analyzeDecision,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Center(
                                child: _isAnalyzing
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Analiz Et',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),
                // Bilgi Kartı
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Nasıl Çalışır?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _InfoItem(
                        icon: Icons.psychology_outlined,
                        text: 'AI, kararınızı analiz eder ve bir karar ağacı oluşturur',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      _InfoItem(
                        icon: Icons.how_to_vote_outlined,
                        text: 'İki ana seçenek otomatik olarak topluluk oylamasına açılır',
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      _InfoItem(
                        icon: Icons.location_on_outlined,
                        text: 'Mekanla ilgili kararlar için canlı durum bilgisi alabilirsiniz',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Bilgi Öğesi Widget'ı
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }
}

class DecisionResultScreen extends StatefulWidget {
  final Decision decision;

  const DecisionResultScreen({super.key, required this.decision});

  @override
  State<DecisionResultScreen> createState() => _DecisionResultScreenState();
}

class _DecisionResultScreenState extends State<DecisionResultScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? _decisionId;

  @override
  void initState() {
    super.initState();
    _decisionId = widget.decision.id.isNotEmpty ? widget.decision.id : null;
  }

  /// Analysis metninden JSON formatını temizler, sadece metin kısmını döndürür
  String _cleanAnalysisText(String analysis) {
    if (analysis.isEmpty) return analysis;
    
    // JSON formatını temizle
    String cleaned = analysis;
    
    // Eğer JSON objesi içeriyorsa, sadece analysis kısmını al
    if (cleaned.contains('"analysis"') || cleaned.contains("'analysis'")) {
      // JSON'dan analysis değerini çıkar (çift tırnak)
      final analysisPattern1 = RegExp(r'"analysis"\s*:\s*"([^"]+)"', caseSensitive: false);
      final match1 = analysisPattern1.firstMatch(cleaned);
      if (match1 != null && match1.group(1) != null) {
        return match1.group(1)!;
      }
      // JSON'dan analysis değerini çıkar (tek tırnak)
      final analysisPattern2 = RegExp(r"'analysis'\s*:\s*'([^']+)'", caseSensitive: false);
      final match2 = analysisPattern2.firstMatch(cleaned);
      if (match2 != null && match2.group(1) != null) {
        return match2.group(1)!;
      }
    }
    
    // Markdown code block'ları temizle
    cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');
    
    // JSON objelerini temizle (basit yaklaşım)
    cleaned = cleaned.replaceAll(RegExp(r'\{[^{}]*"analysis"[^{}]*\}'), '');
    
    // Fazla boşlukları temizle
    cleaned = cleaned.trim();
    
    return cleaned.isEmpty ? analysis : cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final currentDecisionId = _decisionId ?? widget.decision.id;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analiz Sonucu'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // Topluluk Oylamasına Sun/Kaldır Butonu - Sabit
            StreamBuilder<Decision?>(
              stream: currentDecisionId.isNotEmpty 
                  ? _firebaseService.getDecisionStream(currentDecisionId)
                  : Stream.value(null),
              builder: (context, decisionSnapshot) {
                final decision = decisionSnapshot.data ?? widget.decision;
                final isSubmittedToVote = decision.isSubmittedToVote;
                String decisionId;
                if (decisionSnapshot.data != null && decisionSnapshot.data!.id.isNotEmpty) {
                  decisionId = decisionSnapshot.data!.id;
                } else if (currentDecisionId.isNotEmpty) {
                  decisionId = currentDecisionId;
                } else {
                  decisionId = widget.decision.id;
                }
                
                if (decisionId.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Consumer<DecisionProvider>(
                    builder: (context, decisionProvider, child) {
                      return ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await decisionProvider.toggleVoteSubmission(
                              decisionId,
                              !isSubmittedToVote,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSubmittedToVote
                                        ? 'Oylamadan kaldırıldı ve tüm oylar silindi'
                                        : 'Oylamaya sunuldu',
                                  ),
                                  backgroundColor: isSubmittedToVote ? Colors.orange : Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Hata: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          isSubmittedToVote ? Icons.remove_circle_outline : Icons.how_to_vote,
                          size: 18,
                        ),
                        label: Text(
                          isSubmittedToVote ? 'Kaldır' : 'Oylamaya Sun',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubmittedToVote 
                              ? Colors.orange.withValues(alpha: 0.1) 
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: isSubmittedToVote ? Colors.orange : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSubmittedToVote ? Colors.orange : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.analytics, size: 18),
                text: 'Analiz',
                height: 48,
              ),
              Tab(
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                text: 'Riskler ve Faydalar',
                height: 48,
              ),
            ],
            labelStyle: const TextStyle(fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
          ),
        ),
        body: TabBarView(
          children: [
            // 1. Sekme: Analiz Sonucu
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: StreamBuilder<Decision?>(
                stream: currentDecisionId.isNotEmpty 
                    ? _firebaseService.getDecisionStream(currentDecisionId)
                    : Stream.value(null),
                builder: (context, decisionSnapshot) {
                  final decision = decisionSnapshot.data ?? widget.decision;
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Soru Kartı
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.help_outline,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Soru',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                decision.question,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 16,
                                      height: 1.6,
                                      color: Colors.grey[800],
                                    ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0),
                        // AI Analiz Bloğu
                        if (decision.decisionTree != null && decision.decisionTree!.analysis.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.purple[50]!,
                                  Colors.purple[100]!.withValues(alpha: 0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.purple[300]!.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withValues(alpha: 0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[400]!.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.psychology_rounded,
                                        color: Colors.purple[700],
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'AI Analiz',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple[700],
                                            fontSize: 20,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _cleanAnalysisText(decision.decisionTree!.analysis),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[800],
                                        height: 1.6,
                                        fontSize: 15,
                                      ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .slideY(begin: 0.1, end: 0),
                        ],
                        if (decision.decisionTree != null) ...[
                          const SizedBox(height: 16),
                          DecisionTreeWidget(tree: decision.decisionTree!),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            // 2. Sekme: Riskler ve Faydalar
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: widget.decision.decisionTree != null &&
                      (widget.decision.decisionTree!.risks.isNotEmpty ||
                          widget.decision.decisionTree!.benefits.isNotEmpty)
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.decision.decisionTree!.risks.isNotEmpty) ...[
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.red[50]!,
                                    Colors.red[100]!.withValues(alpha: 0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.red[300]!.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red[400]!.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Riskler',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[700],
                                              fontSize: 20,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...widget.decision.decisionTree!.risks.map((risk) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(top: 6, right: 12),
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Colors.red[600],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                risk,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: Colors.grey[800],
                                                      height: 1.5,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 200.ms)
                                .slideX(begin: -0.1, end: 0),
                            if (widget.decision.decisionTree!.benefits.isNotEmpty) const SizedBox(height: 24),
                          ],
                          if (widget.decision.decisionTree!.benefits.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green[50]!,
                                    Colors.green[100]!.withValues(alpha: 0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green[300]!.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green[400]!.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.star_rounded, color: Colors.green[700], size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Faydalar',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[700],
                                              fontSize: 20,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...widget.decision.decisionTree!.benefits.map((benefit) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(top: 6, right: 12),
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Colors.green[600],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                benefit,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: Colors.grey[800],
                                                      height: 1.5,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 300.ms)
                                .slideX(begin: 0.1, end: 0),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Riskler ve faydalar henüz analiz edilmedi',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
