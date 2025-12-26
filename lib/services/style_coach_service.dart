import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ai_service.dart';

class StyleCoachService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Gardırop verilerini hazırla
  static Future<String> _getWardrobeContext() async {
    final user = _auth.currentUser;
    if (user == null) return '';

    final snapshot = await _firestore
        .collection('glamora_users')
        .doc(user.uid)
        .collection('wardrobe')
        .get();

    if (snapshot.docs.isEmpty) {
      return 'Kullanıcının gardırobunda henüz hiç kıyafet yok.';
    }

    final items = <String>[];
    final colorCount = <String, int>{};
    final categoryCount = <String, int>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final category = data['category'] ?? 'Other';
      final color = data['colorLabel'] ?? 'Unknown';
      final brand = data['brand'] ?? '';
      
      items.add('- $category ($color)${brand.isNotEmpty ? " - $brand" : ""}');
      
      colorCount[color] = (colorCount[color] ?? 0) + 1;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    final topColors = colorCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return '''
GARDIROB ANALİZİ:
Toplam Parça: ${items.length}

EN ÇOK KULLANILAN RENKLER:
${topColors.take(5).map((e) => '- ${e.key}: ${e.value} parça').join('\n')}

KATEGORİ DAĞILIMI:
${topCategories.map((e) => '- ${e.key}: ${e.value} parça').join('\n')}

TÜM PARÇALAR:
${items.take(30).join('\n')}
${items.length > 30 ? '... ve ${items.length - 30} parça daha' : ''}
''';
  }

  /// AI'dan kişiselleştirilmiş stil önerileri al
  static Future<Map<String, dynamic>> getStyleRecommendations() async {
    final wardrobeContext = await _getWardrobeContext();
    
    if (wardrobeContext.contains('henüz hiç kıyafet yok')) {
      return {
        'outfitSuggestions': [],
        'missingItems': ['Temel parçalar ekleyerek başlayın: beyaz tişört, mavi jean, siyah pantolon'],
        'styleInsights': ['Gardırobunuza kıyafet ekleyerek AI önerilerinden faydalanın!'],
        'colorAdvice': 'Nötr renklerle (beyaz, siyah, gri, lacivert) başlayın.',
        'seasonalTips': 'Her mevsim için temel parçalar edinin.',
      };
    }

    final prompt = '''
Sen profesyonel bir stil danışmanısın. Aşağıdaki gardırop bilgilerine göre kişiselleştirilmiş öneriler ver.

$wardrobeContext

Lütfen aşağıdaki formatta JSON yanıt ver (Türkçe):

{
  "outfitSuggestions": [
    {"name": "Kombin Adı", "items": ["parça1", "parça2", "parça3"], "occasion": "Hangi durum için"},
    {"name": "Başka Kombin", "items": ["parça1", "parça2"], "occasion": "Durum"}
  ],
  "missingItems": ["Gardıropta eksik olan ve eklenmesi gereken parçalar listesi"],
  "styleInsights": ["Stil analizi ve kişiye özel gözlemler"],
  "colorAdvice": "Renk paleti hakkında tavsiye",
  "seasonalTips": "Mevsimsel öneriler"
}

ÖNEMLİ: 
- Sadece gardıropta OLAN parçalardan kombinler öner
- En az 3 farklı kombin öner
- Eksik parçalar bölümünde gardırobu tamamlayacak öneriler ver
''';

    try {
      final response = await AiService.askGemini(prompt);
      
      if (response == null || response.isEmpty) {
        return _getDefaultRecommendations();
      }

      // JSON parse
      String cleanJson = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      // JSON başlangıcını bul
      final startIndex = cleanJson.indexOf('{');
      final endIndex = cleanJson.lastIndexOf('}');
      
      if (startIndex == -1 || endIndex == -1) {
        return _getDefaultRecommendations();
      }
      
      cleanJson = cleanJson.substring(startIndex, endIndex + 1);
      
      final parsed = _parseJson(cleanJson);
      return parsed;
    } catch (e) {
      print('Style Coach Error: $e');
      return _getDefaultRecommendations();
    }
  }

  static Map<String, dynamic> _parseJson(String json) {
    try {
      // Manuel basit JSON parse (dart:convert kullanmadan hata durumunda)
      final result = <String, dynamic>{
        'outfitSuggestions': <Map<String, dynamic>>[],
        'missingItems': <String>[],
        'styleInsights': <String>[],
        'colorAdvice': '',
        'seasonalTips': '',
      };

      // outfitSuggestions parse
      final suggestionsMatch = RegExp(r'"outfitSuggestions"\s*:\s*\[(.*?)\]', dotAll: true).firstMatch(json);
      if (suggestionsMatch != null) {
        final suggestionsStr = suggestionsMatch.group(1) ?? '';
        final outfitMatches = RegExp(r'\{[^{}]*"name"[^{}]*\}').allMatches(suggestionsStr);
        for (final match in outfitMatches) {
          final outfit = match.group(0) ?? '';
          final nameMatch = RegExp(r'"name"\s*:\s*"([^"]*)"').firstMatch(outfit);
          final occasionMatch = RegExp(r'"occasion"\s*:\s*"([^"]*)"').firstMatch(outfit);
          final itemsMatch = RegExp(r'"items"\s*:\s*\[(.*?)\]').firstMatch(outfit);
          
          if (nameMatch != null) {
            final items = <String>[];
            if (itemsMatch != null) {
              final itemsStr = itemsMatch.group(1) ?? '';
              final itemMatches = RegExp(r'"([^"]*)"').allMatches(itemsStr);
              for (final item in itemMatches) {
                items.add(item.group(1) ?? '');
              }
            }
            
            (result['outfitSuggestions'] as List).add({
              'name': nameMatch.group(1) ?? '',
              'items': items,
              'occasion': occasionMatch?.group(1) ?? '',
            });
          }
        }
      }

      // missingItems parse
      final missingMatch = RegExp(r'"missingItems"\s*:\s*\[(.*?)\]', dotAll: true).firstMatch(json);
      if (missingMatch != null) {
        final missingStr = missingMatch.group(1) ?? '';
        final itemMatches = RegExp(r'"([^"]*)"').allMatches(missingStr);
        for (final item in itemMatches) {
          (result['missingItems'] as List).add(item.group(1) ?? '');
        }
      }

      // styleInsights parse
      final insightsMatch = RegExp(r'"styleInsights"\s*:\s*\[(.*?)\]', dotAll: true).firstMatch(json);
      if (insightsMatch != null) {
        final insightsStr = insightsMatch.group(1) ?? '';
        final itemMatches = RegExp(r'"([^"]*)"').allMatches(insightsStr);
        for (final item in itemMatches) {
          (result['styleInsights'] as List).add(item.group(1) ?? '');
        }
      }

      // colorAdvice parse
      final colorMatch = RegExp(r'"colorAdvice"\s*:\s*"([^"]*)"').firstMatch(json);
      if (colorMatch != null) {
        result['colorAdvice'] = colorMatch.group(1) ?? '';
      }

      // seasonalTips parse
      final seasonMatch = RegExp(r'"seasonalTips"\s*:\s*"([^"]*)"').firstMatch(json);
      if (seasonMatch != null) {
        result['seasonalTips'] = seasonMatch.group(1) ?? '';
      }

      return result;
    } catch (e) {
      return _getDefaultRecommendations();
    }
  }

  static Map<String, dynamic> _getDefaultRecommendations() {
    return {
      'outfitSuggestions': [
        {
          'name': 'Günlük Şık',
          'items': ['Tişört', 'Jean', 'Sneaker'],
          'occasion': 'Günlük kullanım',
        },
        {
          'name': 'İş Casual',
          'items': ['Gömlek', 'Pantolon', 'Loafer'],
          'occasion': 'Ofis ortamı',
        },
      ],
      'missingItems': ['Çok yönlü bir ceket', 'Klasik beyaz sneaker', 'Şık bir saat'],
      'styleInsights': ['Gardırobunuz analiz ediliyor...', 'Daha fazla veri için kıyafet ekleyin'],
      'colorAdvice': 'Gardırobunuzdaki renkleri analiz etmek için daha fazla parça ekleyin.',
      'seasonalTips': 'Her mevsim için uygun parçalarınızı değerlendiriyoruz.',
    };
  }

  /// Hızlı günlük kombin önerisi
  static Future<Map<String, dynamic>?> getQuickOutfitSuggestion({
    String? occasion,
    String? weather,
  }) async {
    final wardrobeContext = await _getWardrobeContext();
    
    if (wardrobeContext.contains('henüz hiç kıyafet yok')) {
      return null;
    }

    final occasionText = occasion ?? 'günlük kullanım';
    final weatherText = weather ?? 'normal hava';

    final prompt = '''
Gardıroptaki parçalardan $occasionText için, $weatherText durumuna uygun BİR kombin öner.

$wardrobeContext

Sadece aşağıdaki JSON formatında yanıt ver:
{
  "outfitName": "Kombin adı",
  "items": ["parça1", "parça2", "parça3"],
  "reason": "Neden bu kombini önerdiğin"
}
''';

    try {
      final response = await AiService.askGemini(prompt);
      if (response == null) return null;

      String cleanJson = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final startIndex = cleanJson.indexOf('{');
      final endIndex = cleanJson.lastIndexOf('}');
      
      if (startIndex == -1 || endIndex == -1) return null;
      
      cleanJson = cleanJson.substring(startIndex, endIndex + 1);

      final nameMatch = RegExp(r'"outfitName"\s*:\s*"([^"]*)"').firstMatch(cleanJson);
      final reasonMatch = RegExp(r'"reason"\s*:\s*"([^"]*)"').firstMatch(cleanJson);
      final itemsMatch = RegExp(r'"items"\s*:\s*\[(.*?)\]').firstMatch(cleanJson);

      final items = <String>[];
      if (itemsMatch != null) {
        final itemsStr = itemsMatch.group(1) ?? '';
        final itemMatches = RegExp(r'"([^"]*)"').allMatches(itemsStr);
        for (final item in itemMatches) {
          items.add(item.group(1) ?? '');
        }
      }

      return {
        'outfitName': nameMatch?.group(1) ?? 'Günün Kombini',
        'items': items,
        'reason': reasonMatch?.group(1) ?? '',
      };
    } catch (e) {
      return null;
    }
  }
}
