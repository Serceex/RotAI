import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/decision.dart';

class GeminiService {
  final String apiKey;
  // v1beta API'sini kullan (daha geniş model desteği)
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GeminiService({required this.apiKey});

  /// Mevcut modelleri listele
  Future<List<String>> listAvailableModels() async {
    try {
      final url = Uri.parse('$_baseUrl/models?key=$apiKey');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List?;
        if (models != null) {
          return models
              .map((m) => m['name'] as String)
              .where((name) => name.contains('gemini'))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Çalışan bir model bul
  Future<String?> findWorkingModel() async {
    final availableModels = await listAvailableModels();
    
    // Eğer modeller listesi boşsa, standart modelleri dene
    if (availableModels.isEmpty) {
      // Standart modelleri sırayla dene
      final standardModels = [
        'models/gemini-1.5-flash',
        'models/gemini-1.5-pro',
        'models/gemini-pro',
      ];
      return standardModels.first;
    }
    
    // Mevcut modellerden birini seç
    // Önce flash modeli, sonra pro modeli, son olarak gemini-pro
    final preferredOrder = ['flash', 'pro', 'gemini-pro'];
    
    for (final preference in preferredOrder) {
      for (final model in availableModels) {
        if (model.toLowerCase().contains(preference.toLowerCase())) {
          // Model adını temizle (models/ prefix'i ile)
          final cleanName = model.startsWith('models/') ? model : 'models/$model';
          return cleanName;
        }
      }
    }
    
    // Hiçbiri bulunamazsa, ilk mevcut modeli kullan
    if (availableModels.isNotEmpty) {
      final firstModel = availableModels.first;
      return firstModel.startsWith('models/') ? firstModel : 'models/$firstModel';
    }
    
    return null;
  }

  /// API'yi test et
  Future<Map<String, dynamic>> testApi() async {
    // Önce mevcut modelleri listele
    final availableModels = await listAvailableModels();
    final workingModel = await findWorkingModel();
    
    if (workingModel == null) {
      return {
        'statusCode': 0,
        'success': false,
        'error': 'Hiçbir çalışan model bulunamadı. Mevcut modeller: $availableModels',
        'model': 'N/A',
        'availableModels': availableModels,
      };
    }
    
    final testPrompt = 'Merhaba, bu bir test mesajıdır. Lütfen "Test başarılı" yanıtını ver.';
    
    try {
      final url = Uri.parse('$_baseUrl/$workingModel:generateContent?key=$apiKey');
      
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': testPrompt}
            ]
          }
        ]
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      return {
        'statusCode': response.statusCode,
        'success': response.statusCode == 200,
        'body': response.body.length > 500 
            ? response.body.substring(0, 500) 
            : response.body,
        'model': workingModel,
        'availableModels': availableModels,
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'success': false,
        'error': e.toString(),
        'model': workingModel,
        'availableModels': availableModels,
      };
    }
  }

  Future<DecisionTree> analyzeDecision(String question) async {
    final prompt = '''
Sen bir karar analiz uzmanısın. Kullanıcının şu kararını analiz et ve detaylı bir karar ağacı oluştur:

Karar: $question

Lütfen şunları sağla:
1. Kararın iki ana seçeneğini (A ve B) belirle
2. Her seçeneğin risklerini listele
3. Her seçeneğin faydalarını listele
4. Her seçenek için olası sonuçları ve alt seçenekleri içeren bir karar ağacı yapısı oluştur
5. Genel bir analiz özeti yaz
6. Analiz sonucuna göre hangi seçeneğin daha mantıklı/doğru olduğunu belirle (recommendedOption: "A" veya "B")

Yanıtını JSON formatında ver:
{
  "optionA": "Seçenek A açıklaması",
  "optionB": "Seçenek B açıklaması",
  "analysis": "Genel analiz metni",
  "risks": ["Risk 1", "Risk 2", ...],
  "benefits": ["Fayda 1", "Fayda 2", ...],
  "recommendedOption": "A" veya "B",
  "tree": {
    "id": "root",
    "label": "Ana Karar",
    "description": "Açıklama",
    "children": [
      {
        "id": "optionA",
        "label": "Seçenek A",
        "description": "Açıklama",
        "children": [...],
        "outcome": "Olası sonuç"
      },
      {
        "id": "optionB",
        "label": "Seçenek B",
        "description": "Açıklama",
        "children": [...],
        "outcome": "Olası sonuç"
      }
    ]
  }
}
''';

    // Doğrudan HTTP isteği ile Gemini API'yi çağır
    // Önce çalışan bir model bul
    final workingModel = await findWorkingModel();
    
    if (workingModel == null) {
      throw Exception(
        '❌ Gemini API: Hiçbir çalışan model bulunamadı.\n\n'
        'Lütfen API anahtarınızı ve Generative Language API\'nin etkin olduğunu kontrol edin.'
      );
    }
    
    try {
      final url = Uri.parse('$_baseUrl/$workingModel:generateContent?key=$apiKey');
      
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      };

      // Timeout ve retry mekanizması ile istek gönder
      http.Response? response;
      int retryCount = 0;
      const maxRetries = 3;
      const timeoutDuration = Duration(seconds: 30);
      
      while (retryCount < maxRetries) {
        try {
          response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          ).timeout(timeoutDuration);
          break; // Başarılı ise döngüden çık
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            // Son deneme de başarısız oldu
            if (e.toString().contains('timeout') || 
                e.toString().contains('abort') || 
                e.toString().contains('Connection')) {
              throw Exception(
                '⏱️ Bağlantı Hatası\n\n'
                'Gemini API\'ye bağlanırken sorun oluştu.\n\n'
                'Yapılacaklar:\n'
                '1. İnternet bağlantınızı kontrol edin\n'
                '2. Birkaç saniye bekleyip tekrar deneyin\n'
                '3. VPN kullanıyorsanız kapatmayı deneyin\n\n'
                'Hata: ${e.toString()}'
              );
            }
            throw Exception('Gemini API bağlantı hatası: $e');
          }
          // Kısa bir bekleme sonrası tekrar dene
          await Future.delayed(Duration(seconds: 2 * retryCount));
        }
      }
      
      if (response == null) {
        throw Exception('Gemini API\'ye bağlanılamadı');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final candidates = responseData['candidates'] as List?;
        
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String? ?? '';
            
            if (text.isNotEmpty) {
              return _parseResponse(text, question);
            }
          }
        }
        
        throw Exception('Gemini API boş yanıt döndü');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          '🔑 API Anahtarı Hatası (HTTP ${response.statusCode})\n\n'
          'API anahtarınız geçersiz veya yetkilendirme sorunu var.\n\n'
          'Yapılacaklar:\n'
          '1. https://makersuite.google.com/app/apikey adresine gidin\n'
          '2. Yeni bir API anahtarı oluşturun\n'
          '3. lib/config/api_config.dart dosyasındaki geminiApiKey değerini güncelleyin\n\n'
          'API Yanıtı: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}'
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          '❌ Model Bulunamadı (HTTP 404)\n\n'
          'Model: $workingModel\n'
          'Bu model v1beta API\'sinde bulunamadı.\n\n'
          'Lütfen API anahtarınızı ve Generative Language API\'nin etkin olduğunu kontrol edin.\n\n'
          'Yanıt: ${response.body.length > 300 ? response.body.substring(0, 300) : response.body}'
        );
      } else {
        throw Exception(
          '❌ Gemini API Hatası (HTTP ${response.statusCode})\n\n'
          'Model: $workingModel\n'
          'Yanıt: ${response.body.length > 300 ? response.body.substring(0, 300) : response.body}'
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Gemini API hatası: $e');
    }
  }

  DecisionTree _parseResponse(String response, String question) {
    String cleanAnalysis = '';
    String optionA = '';
    String optionB = '';
    List<String> risks = [];
    List<String> benefits = [];
    String? recommendedOption;

    // JSON parse etmeyi dene
    try {
      // JSON bloğunu bul (```json ... ``` veya { ... } formatında)
      String jsonText = response;
      
      // Markdown code block'ları temizle
      if (jsonText.contains('```json')) {
        final start = jsonText.indexOf('```json') + 7;
        final end = jsonText.indexOf('```', start);
        if (end != -1) {
          jsonText = jsonText.substring(start, end).trim();
        }
      } else if (jsonText.contains('```')) {
        final start = jsonText.indexOf('```') + 3;
        final end = jsonText.indexOf('```', start);
        if (end != -1) {
          jsonText = jsonText.substring(start, end).trim();
        }
      }
      
      // JSON objesini bul
      final jsonStart = jsonText.indexOf('{');
      final jsonEnd = jsonText.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = jsonText.substring(jsonStart, jsonEnd + 1);
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        
        // JSON'dan verileri çıkar
        optionA = jsonData['optionA']?.toString() ?? '';
        optionB = jsonData['optionB']?.toString() ?? '';
        cleanAnalysis = jsonData['analysis']?.toString() ?? '';
        recommendedOption = jsonData['recommendedOption']?.toString();
        
        if (jsonData['risks'] != null) {
          risks = List<String>.from(jsonData['risks'] as List);
        }
        if (jsonData['benefits'] != null) {
          benefits = List<String>.from(jsonData['benefits'] as List);
        }
      }
    } catch (e) {
      // JSON parse edilemezse, metni temizle
      cleanAnalysis = response;
    }
    
    // Eğer JSON parse edilemediyse, metni temizle ve optionA/optionB'yi bul
    if (optionA.isEmpty && optionB.isEmpty) {
      // JSON formatını temizle
      cleanAnalysis = response
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .replaceAll(RegExp(r'\{[^}]*\}'), '')
          .trim();
      
      // optionA ve optionB'yi metinden çıkarmaya çalış
      final optionAPattern = RegExp(r'"optionA"\s*:\s*"([^"]+)"', caseSensitive: false);
      final optionBPattern = RegExp(r'"optionB"\s*:\s*"([^"]+)"', caseSensitive: false);
      
      final optionAMatch = optionAPattern.firstMatch(response);
      final optionBMatch = optionBPattern.firstMatch(response);
      
      if (optionAMatch != null) {
        optionA = optionAMatch.group(1) ?? '';
      }
      if (optionBMatch != null) {
        optionB = optionBMatch.group(1) ?? '';
      }
    }
    
    // Temiz analiz metni (JSON olmadan)
    if (cleanAnalysis.isEmpty) {
      // Eğer hala JSON içeriyorsa, sadece analysis kısmını al
      final analysisPattern = RegExp(r'"analysis"\s*:\s*"([^"]+)"', caseSensitive: false);
      final analysisMatch = analysisPattern.firstMatch(response);
      if (analysisMatch != null) {
        cleanAnalysis = analysisMatch.group(1) ?? '';
      } else {
        // JSON'dan temizle
        cleanAnalysis = response
            .replaceAll(RegExp(r'\{[^}]*\}'), '')
            .replaceAll(RegExp(r'```[^`]*```'), '')
            .trim();
      }
    }
    
    // Varsayılan değerler
    if (cleanAnalysis.isEmpty) {
      cleanAnalysis = 'Analiz rotası tamamlandı.';
    }
    if (risks.isEmpty) {
      risks = ['Risk analizi yapılıyor...'];
    }
    if (benefits.isEmpty) {
      benefits = ['Fayda analizi yapılıyor...'];
    }
    
    final rootNode = DecisionNode(
      id: 'root',
      label: 'Ana Karar',
      description: question,
      children: [
        DecisionNode(
          id: 'optionA',
          label: 'Seçenek 1',
          description: optionA.isNotEmpty && optionA.length < 100 ? optionA : null,
          outcome: optionA.isNotEmpty ? optionA : 'Seçenek 1\'in olası sonuçları',
        ),
        DecisionNode(
          id: 'optionB',
          label: 'Seçenek 2',
          description: optionB.isNotEmpty && optionB.length < 100 ? optionB : null,
          outcome: optionB.isNotEmpty ? optionB : 'Seçenek 2\'nin olası sonuçları',
        ),
      ],
    );

    return DecisionTree(
      analysis: cleanAnalysis,
      rootNode: rootNode,
      risks: risks,
      benefits: benefits,
      recommendedOption: recommendedOption,
    );
  }
}

