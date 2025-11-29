import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/decision_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/decision.dart';
import '../../models/expert.dart';
import '../../models/expert_comment.dart';
import '../../services/firebase_service.dart';
import '../../services/expert_service.dart';
import '../../widgets/expert_comment_card.dart';
import 'decision_tree_widget.dart';

class DecisionAnalysisScreen extends StatefulWidget {
  const DecisionAnalysisScreen({super.key});

  @override
  State<DecisionAnalysisScreen> createState() => _DecisionAnalysisScreenState();
}

class _DecisionAnalysisScreenState extends State<DecisionAnalysisScreen> {
  final _questionController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }


  Future<void> _analyzeDecision() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir karar sorusu girin')),
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
        userId: userId,
      );

      // Decision zaten doğru userRef ile oluşturuldu
      final decisionWithUser = decision;

      // Analizi otomatik kaydetme - sadece göster
      // Kullanıcı "Topluluk Oylamasına Sun" butonuna tıkladığında kaydedilecek

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DecisionResultScreen(decision: decisionWithUser),
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
                // Başlık
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dönen gradient halka
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 3),
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: value * 2 * 3.14159, // 360 derece
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: SweepGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                      Theme.of(context).colorScheme.primary,
                                    ],
                                    stops: const [0.0, 0.5, 0.75, 1.0],
                                  ),
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            // Animasyonu tekrar başlat
                            setState(() {});
                          },
                        ),
                        // İç beyaz arka plan
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        // İkon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.psychology_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analiz Rotası',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI destekli analiz rotası',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 40),
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit_note,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _questionController,
                          maxLines: 6,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
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
  String? _decisionId; // Decision kaydedildikten sonra ID'yi tutmak için

  @override
  void initState() {
    super.initState();
    // Decision'ın ID'si varsa kullan (timestamp ID olabilir, Firestore'da kontrol edilecek)
    _decisionId = widget.decision.id.isNotEmpty ? widget.decision.id : null;
  }

  @override
  Widget build(BuildContext context) {
    // Decision ID'yi kullan (eğer kaydedildiyse güncel ID, değilse widget'tan gelen)
    final currentDecisionId = _decisionId ?? widget.decision.id;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Rotası Sonucu'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
        child: StreamBuilder<Decision?>(
        stream: currentDecisionId.isNotEmpty 
            ? _firebaseService.getDecisionStream(currentDecisionId)
            : Stream.value(null),
        builder: (context, decisionSnapshot) {
          // Decision'ın oylamaya sunulup sunulmadığını kontrol et
          final decision = decisionSnapshot.data;
          final isSubmittedToVote = decision?.isSubmittedToVote ?? widget.decision.isSubmittedToVote;
          final showRemoveButton = isSubmittedToVote;
          
          return Column(
            children: [
              // Sticky buton - en üstte
              SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: showRemoveButton
                            ? [Colors.red[400]!, Colors.red[600]!]
                            : [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (showRemoveButton
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary)
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                    if (showRemoveButton) {
                      // Oyları kaldır ve decision'ı sil
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Oylamayı Kaldır'),
                          content: const Text(
                            'Bu kararı topluluk oylamasından kaldırmak istediğinizden emin misiniz? Tüm oylar silinecektir.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Kaldır'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        try {
                          // Oyları sil
                          if (currentDecisionId.isNotEmpty) {
                            await _firebaseService.deleteVotesForDecision(currentDecisionId);
                            
                            // Decision'ın isSubmittedToVote flag'ini false yap
                            await _firebaseService.updateDecision(
                              currentDecisionId,
                              {'isSubmittedToVote': false},
                            );
                          }
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Oylama kaldırıldı'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Hata: ${e.toString()}'),
                              ),
                            );
                          }
                        }
                      }
                    } else {
                      // Oylamaya sun - sadece kaydet, ekran açma
                      try {
                        String savedDecisionId;
                        
                        // Eğer decision zaten Firestore'da kaydedilmişse, sadece flag'i güncelle
                        if (currentDecisionId.isNotEmpty) {
                          final existingDecision = await _firebaseService.getDecision(currentDecisionId);
                          if (existingDecision != null) {
                            // Decision zaten kaydedilmiş, sadece flag'i güncelle
                            await _firebaseService.updateDecision(
                              currentDecisionId,
                              {'isSubmittedToVote': true},
                            );
                            savedDecisionId = currentDecisionId;
                          } else {
                            // Decision yok, yeni kaydet (createDecision duplicate kontrolü yapacak)
                            final decisionProvider =
                                Provider.of<DecisionProvider>(context, listen: false);
                            savedDecisionId = await decisionProvider.saveDecision(widget.decision);
                            // State'i güncelle
                            setState(() {
                              _decisionId = savedDecisionId;
                            });
                          }
                        } else {
                          // Decision hiç kaydedilmemiş, yeni kaydet (createDecision duplicate kontrolü yapacak)
                          final decisionProvider =
                              Provider.of<DecisionProvider>(context, listen: false);
                          savedDecisionId = await decisionProvider.saveDecision(widget.decision);
                          // State'i güncelle
                          setState(() {
                            _decisionId = savedDecisionId;
                          });
                        }
                        
                        if (!mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Karar topluluk oylamasına eklendi'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Karar kaydedilirken hata oluştu: ${e.toString()}'),
                          ),
                        );
                      }
                    }
                  },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  showRemoveButton
                                      ? Icons.remove_circle_outline
                                      : Icons.how_to_vote,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  showRemoveButton
                                      ? 'Topluluk Oylamasından Kaldır'
                                      : 'Topluluk Oylamasına Sun',
                                  style: const TextStyle(
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
                ),
              // Scrollable içerik
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              widget.decision.question,
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
            if (widget.decision.decisionTree != null) ...[
              const SizedBox(height: 24),
              // Analiz Bölümü - Modern tasarım
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                      Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'AI Analizi',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 400,
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          widget.decision.decisionTree!.analysis,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.8,
                                letterSpacing: 0.3,
                                fontSize: 15,
                                color: Colors.grey[800],
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
              // Riskler ve Faydalar
              if (widget.decision.decisionTree!.risks.isNotEmpty || widget.decision.decisionTree!.benefits.isNotEmpty) ...[
                const SizedBox(height: 24),
                if (widget.decision.decisionTree!.risks.isNotEmpty)
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
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideX(begin: -0.1, end: 0),
                if (widget.decision.decisionTree!.risks.isNotEmpty && widget.decision.decisionTree!.benefits.isNotEmpty)
                  const SizedBox(height: 16),
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
                      .fadeIn(duration: 500.ms, delay: 400.ms)
                      .slideX(begin: 0.1, end: 0),
              ],
              const SizedBox(height: 16),
              DecisionTreeWidget(tree: widget.decision.decisionTree!),
              
              // Uzman Görüşleri Bölümü
              const SizedBox(height: 32),
              _ExpertCommentsSection(decisionId: widget.decision.id),
            ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }
}

// Uzman Görüşleri Bölümü Widget'ı
class _ExpertCommentsSection extends StatelessWidget {
  final String decisionId;

  const _ExpertCommentsSection({required this.decisionId});

  @override
  Widget build(BuildContext context) {
    if (decisionId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9EB0C7), Color(0xFF8FA0B8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9EB0C7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.people_alt_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Uzman Görüşleri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: const Color(0xFF9EB0C7),
                  ),
            ),
            const Spacer(),
            // Uzman görüşü iste butonu
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showExpertSelectionDialog(context, decisionId),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9EB0C7), Color(0xFF8FA0B8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_comment_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Görüş İste',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Uzman yorumları listesi
        StreamBuilder<List<ExpertComment>>(
          stream: ExpertService().getExpertComments(decisionId),
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
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Yorumlar yüklenirken hata oluştu',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              );
            }

            final comments = snapshot.data ?? [];

            if (comments.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Henüz uzman görüşü yok',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Uzmanlardan görüş istemek için yukarıdaki butona tıklayın',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: comments.map((comment) {
                return ExpertCommentCard(comment: comment);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showExpertSelectionDialog(BuildContext context, String decisionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExpertSelectionModal(decisionId: decisionId),
    );
  }
}

// Uzman Seçim Modal'ı
class _ExpertSelectionModal extends StatefulWidget {
  final String decisionId;

  const _ExpertSelectionModal({required this.decisionId});

  @override
  State<_ExpertSelectionModal> createState() => _ExpertSelectionModalState();
}

class _ExpertSelectionModalState extends State<_ExpertSelectionModal> {
  final ExpertService _expertService = ExpertService();
  final TextEditingController _commentController = TextEditingController();
  Expert? _selectedExpert;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_selectedExpert == null || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen uzman seçin ve yorum yazın')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _expertService.addExpertComment(
        decisionId: widget.decisionId,
        expertId: _selectedExpert!.id,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uzman görüşü eklendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Başlık
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9EB0C7), Color(0xFF8FA0B8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people_alt_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Uzman Seç',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Uzman listesi
          Expanded(
            child: FutureBuilder<List<Expert>>(
              future: _expertService.getAllVerifiedExperts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Hata: ${snapshot.error}'),
                  );
                }

                final experts = snapshot.data ?? [];

                if (experts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Henüz onaylanmış uzman yok'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await _expertService.createDemoExpert();
                            setState(() {}); // Listeyi yenile
                          },
                          child: const Text('Demo Uzman Oluştur'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: experts.length,
                  itemBuilder: (context, index) {
                    final expert = experts[index];
                    final isSelected = _selectedExpert?.id == expert.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF9EB0C7).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF9EB0C7)
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _selectedExpert = expert),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF9EB0C7), Color(0xFF8FA0B8)],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              expert.displayName ?? 'Uzman',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (expert.verified) ...[
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.verified,
                                              color: Colors.blue.shade600,
                                              size: 16,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        expert.expertise.take(2).join(', '),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF9EB0C7),
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Alt buton
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedExpert == null
                      ? null
                      : () {
                          // Yorum yazma dialog'u göster
                          _showCommentDialog();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9EB0C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Devam Et',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Uzman Görüşü'),
        content: TextField(
          controller: _commentController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Uzmanın görüşünü yazın...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitComment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9EB0C7),
              foregroundColor: Colors.white,
            ),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
