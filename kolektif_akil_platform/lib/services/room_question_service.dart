import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/decision.dart';
import '../models/escape_room.dart';
import '../services/gemini_service.dart';
import '../utils/categories.dart';

class RoomQuestionService {
  final GeminiService _geminiService;

  RoomQuestionService({required GeminiService geminiService})
      : _geminiService = geminiService;

  // Kategoriye göre hazır soru oluştur
  Future<Decision> generateQuestionForCategory(
      String categoryId, DifficultyLevel difficulty) async {
    final category = Categories.getById(categoryId);
    final categoryName = category?.name ?? 'Genel';

    final prompt = '''
Bir karar escape room oyunu için soru oluştur.

Kategori: $categoryName
Zorluk: ${difficulty.label}

Lütfen şu formatta bir karar sorusu oluştur:
- İki seçenekli bir karar sorusu
- Zorluk seviyesine uygun karmaşıklıkta
- İlgi çekici ve düşündürücü
- Kategoriyle ilgili

Soru formatı: "Soru metni"
Seçenek A: "Seçenek A açıklaması"
Seçenek B: "Seçenek B açıklaması"

JSON formatında döndür:
{
  "question": "Soru metni",
  "optionA": "Seçenek A",
  "optionB": "Seçenek B",
  "recommendedOption": "A" veya "B"
}
''';

    try {
      // Gemini API ile soru oluştur
      // Şimdilik fallback kullan
      return _getFallbackQuestion(categoryId, difficulty);
    } catch (e) {
      return _getFallbackQuestion(categoryId, difficulty);
    }
  }

  Decision _getFallbackQuestion(String categoryId, DifficultyLevel difficulty) {
    final fallbackQuestions = {
      'career': {
        'question': 'Yeni bir iş teklifi aldınız. Daha yüksek maaşlı ama uzak bir şehirdeki pozisyon mu, yoksa mevcut işinizde kalıp terfi beklemek mi?',
        'optionA': 'Yeni işi kabul et, daha yüksek maaş ve kariyer fırsatları',
        'optionB': 'Mevcut işte kal, tanıdık ortam ve istikrar',
      },
      'finance': {
        'question': 'Birikimlerinizi nasıl değerlendirmelisiniz?',
        'optionA': 'Riskli ama yüksek getirili yatırımlar',
        'optionB': 'Güvenli ama düşük getirili yatırımlar',
      },
      'health': {
        'question': 'Sağlık sorununuz için hangi yaklaşımı tercih edersiniz?',
        'optionA': 'Geleneksel tıbbi tedavi',
        'optionB': 'Alternatif ve doğal tedavi yöntemleri',
      },
    };

    final questionData = fallbackQuestions[categoryId] ??
        {
          'question': 'Önemli bir karar vermeniz gerekiyor. Hangi seçeneği tercih edersiniz?',
          'optionA': 'Seçenek A',
          'optionB': 'Seçenek B',
        };

    // Geçici bir Decision oluştur (ID ve userRef gerekli değil çünkü sadece soru için)
    return Decision(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userRef: FirebaseFirestore.instance.collection('users').doc('system'),
      question: questionData['question']!,
      optionA: questionData['optionA']!,
      optionB: questionData['optionB']!,
      createdAt: DateTime.now(),
    );
  }
}

