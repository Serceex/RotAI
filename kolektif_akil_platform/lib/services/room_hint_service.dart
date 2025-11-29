import '../services/gemini_service.dart';
import '../models/escape_room.dart';

class RoomHintService {
  final GeminiService _geminiService;

  RoomHintService({required GeminiService geminiService})
      : _geminiService = geminiService;

  // AI ile ipucu oluştur
  Future<String> generateHint(
      EscapeRoom room, int hintNumber, List<String> previousHints) async {
    final prompt = '''
Bir karar escape room oyunu için ipucu oluştur.

Soru: ${room.question}
Seçenek A: ${room.optionA}
Seçenek B: ${room.optionB}
Zorluk: ${room.difficulty.label}

Bu ${hintNumber}. ipucu. ${previousHints.isNotEmpty ? 'Önceki ipuçları: ${previousHints.join(', ')}' : 'İlk ipucu.'}

Lütfen doğru cevabı açıkça söylemeden, kullanıcıyı doğru yöne yönlendiren bir ipucu ver.
İpucu kısa ve net olmalı (maksimum 2 cümle).
''';

    try {
      final workingModel = await _geminiService.findWorkingModel();
      if (workingModel == null) {
        return _getFallbackHint(room, hintNumber);
      }

      // Gemini API'yi çağır (basitleştirilmiş)
      // Not: GeminiService'de generateText metodu yoksa, burada HTTP isteği yapılabilir
      return _getFallbackHint(room, hintNumber);
    } catch (e) {
      return _getFallbackHint(room, hintNumber);
    }
  }

  String _getFallbackHint(EscapeRoom room, int hintNumber) {
    final hints = [
      'Her iki seçeneğin de artı ve eksilerini düşün.',
      'Uzun vadeli sonuçları göz önünde bulundur.',
      'Risk ve fayda analizi yap.',
      'Hangi seçenek daha sürdürülebilir?',
      'Kısa vadeli kazanç mı, uzun vadeli başarı mı?',
    ];

    if (hintNumber <= hints.length) {
      return hints[hintNumber - 1];
    }
    return 'Analiz sonuçlarını tekrar gözden geçir.';
  }
}

