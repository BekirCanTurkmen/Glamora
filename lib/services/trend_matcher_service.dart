import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ai_service.dart';

class TrendMatcherService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Gardırop verilerini hazırla
  static Future<Map<String, dynamic>> _getWardrobeData() async {
    final user = _auth.currentUser;
    if (user == null) return {'items': [], 'colors': {}, 'categories': {}};

    final snapshot = await _firestore
        .collection('glamora_users')
        .doc(user.uid)
        .collection('wardrobe')
        .get();

    final items = <Map<String, dynamic>>[];
    final colorCount = <String, int>{};
    final categoryCount = <String, int>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final category = (data['category'] ?? 'Other').toString();
      final color = (data['colorLabel'] ?? 'Unknown').toString();
      
      items.add({
        'category': category,
        'color': color,
        'brand': data['brand'] ?? '',
      });
      
      colorCount[color] = (colorCount[color] ?? 0) + 1;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return {
      'items': items,
      'colors': colorCount,
      'categories': categoryCount,
      'totalItems': items.length,
    };
  }

  /// AI'dan güncel trendleri ve gardırop eşleşmesini al
  static Future<Map<String, dynamic>> getTrendMatches() async {
    final wardrobeData = await _getWardrobeData();
    
    if ((wardrobeData['totalItems'] as int) == 0) {
      return {
        'trends': [],
        'overallMatch': 0,
        'suggestions': ['Gardırobunuza kıyafet ekleyerek trend analizi yapabilirsiniz.'],
      };
    }

    final currentMonth = DateTime.now().month;
    final season = _getSeason(currentMonth);
    final year = DateTime.now().year;

    final prompt = '''
Sen profesyonel bir moda trend analistisin. $year yılı $season sezonu için güncel moda trendlerini analiz et ve kullanıcının gardırobuyla eşleştir.

KULLANICININ GARDIROBU:
- Toplam Parça: ${wardrobeData['totalItems']}
- Renkler: ${(wardrobeData['colors'] as Map).entries.map((e) => '${e.key}: ${e.value}').join(', ')}
- Kategoriler: ${(wardrobeData['categories'] as Map).entries.map((e) => '${e.key}: ${e.value}').join(', ')}

Lütfen aşağıdaki JSON formatında yanıt ver (Türkçe):

{
  "trends": [
    {
      "name": "Trend Adı",
      "description": "Trend açıklaması",
      "matchPercentage": 75,
      "matchingItems": ["Eşleşen parça 1", "Eşleşen parça 2"],
      "missingItems": ["Trendi tamamlamak için eksik parça"],
      "icon": "checkroom",
      "color": "#667eea"
    }
  ],
  "overallMatch": 65,
  "topMatchingTrend": "En uygun trend adı",
  "suggestions": ["Genel öneri 1", "Genel öneri 2"],
  "seasonalTip": "Mevsimsel ipucu"
}

ÖNEMLİ:
- En az 5 farklı güncel trend belirle
- Her trend için gardıropta eşleşen parçaları belirle
- matchPercentage 0-100 arası olsun
- Gerçekçi ve güncel trendler kullan
''';

    try {
      final response = await AiService.askGemini(prompt);
      
      if (response == null || response.isEmpty) {
        return _getDefaultTrends();
      }

      // JSON parse
      String cleanJson = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final startIndex = cleanJson.indexOf('{');
      final endIndex = cleanJson.lastIndexOf('}');
      
      if (startIndex == -1 || endIndex == -1) {
        return _getDefaultTrends();
      }
      
      cleanJson = cleanJson.substring(startIndex, endIndex + 1);
      
      final parsed = _parseJson(cleanJson);
      
      // Eğer trends boş döndüyse, varsayılan trendleri kullan
      final trends = parsed['trends'] as List? ?? [];
      if (trends.isEmpty) {
        return _getDefaultTrends();
      }
      
      return parsed;
    } catch (e) {
      print('Trend Matcher Error: $e');
      return _getDefaultTrends();
    }
  }

  static String _getSeason(int month) {
    if (month >= 3 && month <= 5) return 'İlkbahar';
    if (month >= 6 && month <= 8) return 'Yaz';
    if (month >= 9 && month <= 11) return 'Sonbahar';
    return 'Kış';
  }

  static Map<String, dynamic> _parseJson(String json) {
    try {
      final result = <String, dynamic>{
        'trends': <Map<String, dynamic>>[],
        'overallMatch': 0,
        'topMatchingTrend': '',
        'suggestions': <String>[],
        'seasonalTip': '',
      };

      // trends parse
      final trendsMatch = RegExp(r'"trends"\s*:\s*\[(.*?)\](?=\s*,\s*"[a-zA-Z]|\s*\})', dotAll: true).firstMatch(json);
      if (trendsMatch != null) {
        final trendsStr = trendsMatch.group(1) ?? '';
        final trendMatches = RegExp(r'\{[^{}]*"name"[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').allMatches(trendsStr);
        
        for (final match in trendMatches) {
          final trendStr = match.group(0) ?? '';
          
          final nameMatch = RegExp(r'"name"\s*:\s*"([^"]*)"').firstMatch(trendStr);
          final descMatch = RegExp(r'"description"\s*:\s*"([^"]*)"').firstMatch(trendStr);
          final percentMatch = RegExp(r'"matchPercentage"\s*:\s*(\d+)').firstMatch(trendStr);
          final iconMatch = RegExp(r'"icon"\s*:\s*"([^"]*)"').firstMatch(trendStr);
          final colorMatch = RegExp(r'"color"\s*:\s*"([^"]*)"').firstMatch(trendStr);
          
          final matchingItems = <String>[];
          final matchingMatch = RegExp(r'"matchingItems"\s*:\s*\[(.*?)\]').firstMatch(trendStr);
          if (matchingMatch != null) {
            final itemsStr = matchingMatch.group(1) ?? '';
            final itemMatches = RegExp(r'"([^"]*)"').allMatches(itemsStr);
            for (final item in itemMatches) {
              matchingItems.add(item.group(1) ?? '');
            }
          }
          
          final missingItems = <String>[];
          final missingMatch = RegExp(r'"missingItems"\s*:\s*\[(.*?)\]').firstMatch(trendStr);
          if (missingMatch != null) {
            final itemsStr = missingMatch.group(1) ?? '';
            final itemMatches = RegExp(r'"([^"]*)"').allMatches(itemsStr);
            for (final item in itemMatches) {
              missingItems.add(item.group(1) ?? '');
            }
          }
          
          if (nameMatch != null) {
            (result['trends'] as List).add({
              'name': nameMatch.group(1) ?? '',
              'description': descMatch?.group(1) ?? '',
              'matchPercentage': int.tryParse(percentMatch?.group(1) ?? '0') ?? 0,
              'matchingItems': matchingItems,
              'missingItems': missingItems,
              'icon': iconMatch?.group(1) ?? 'checkroom',
              'color': colorMatch?.group(1) ?? '#667eea',
            });
          }
        }
      }

      // overallMatch parse
      final overallMatch = RegExp(r'"overallMatch"\s*:\s*(\d+)').firstMatch(json);
      if (overallMatch != null) {
        result['overallMatch'] = int.tryParse(overallMatch.group(1) ?? '0') ?? 0;
      }

      // topMatchingTrend parse
      final topMatch = RegExp(r'"topMatchingTrend"\s*:\s*"([^"]*)"').firstMatch(json);
      if (topMatch != null) {
        result['topMatchingTrend'] = topMatch.group(1) ?? '';
      }

      // suggestions parse
      final suggestionsMatch = RegExp(r'"suggestions"\s*:\s*\[(.*?)\]', dotAll: true).firstMatch(json);
      if (suggestionsMatch != null) {
        final suggestionsStr = suggestionsMatch.group(1) ?? '';
        final itemMatches = RegExp(r'"([^"]*)"').allMatches(suggestionsStr);
        for (final item in itemMatches) {
          (result['suggestions'] as List).add(item.group(1) ?? '');
        }
      }

      // seasonalTip parse
      final seasonalMatch = RegExp(r'"seasonalTip"\s*:\s*"([^"]*)"').firstMatch(json);
      if (seasonalMatch != null) {
        result['seasonalTip'] = seasonalMatch.group(1) ?? '';
      }

      return result;
    } catch (e) {
      return _getDefaultTrends();
    }
  }

  static Map<String, dynamic> _getDefaultTrends() {
    return {
      'trends': [
        {
          'name': 'Minimalist Chic',
          'description': 'Sade ve zarif parçalarla oluşturulan minimal tarz',
          'matchPercentage': 60,
          'matchingItems': ['Düz renk tişört', 'Klasik jean'],
          'missingItems': ['Beyaz sneaker', 'Oversize blazer'],
          'icon': 'style',
          'color': '#667eea',
        },
        {
          'name': 'Layered Look',
          'description': 'Katmanlı giyim trendi',
          'matchPercentage': 45,
          'matchingItems': ['Tişört', 'Gömlek'],
          'missingItems': ['İnce hırka', 'Yelek'],
          'icon': 'layers',
          'color': '#764ba2',
        },
        {
          'name': 'Earth Tones',
          'description': 'Toprak tonları ve doğal renkler',
          'matchPercentage': 50,
          'matchingItems': ['Kahverengi parçalar'],
          'missingItems': ['Bej pantolon', 'Haki ceket'],
          'icon': 'eco',
          'color': '#8D6E63',
        },
      ],
      'overallMatch': 52,
      'topMatchingTrend': 'Minimalist Chic',
      'suggestions': [
        'Gardırobunuza nötr renkler ekleyin',
        'Katmanlı giyim için ince üst parçalar edinin',
      ],
      'seasonalTip': 'Bu sezon toprak tonları ve minimal tasarımlar öne çıkıyor.',
    };
  }
}
