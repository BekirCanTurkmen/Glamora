import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart'; // Tarih formatı için (Eğer hata verirse: flutter pub add intl)
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  // API Key'i .env dosyasından oku
  static String get apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    return key;
  }

  // Modeli burada tanımlıyoruz
  static GenerativeModel get model => GenerativeModel(
    model: 'gemini-2.0-flash-exp', 
    apiKey: apiKey,
  );

  /// 1️⃣ Normal Sohbet Fonksiyonu (İyileştirilmiş)
  static Future<String?> askGemini(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      
      // 30 saniye timeout ekle
      final response = await model.generateContent(content).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('AI request timed out. Please try again.');
        },
      );
      
      if (response.text == null || response.text!.isEmpty) {
        return 'AI did not return a valid response.';
      }
      
      return response.text;
    } catch (e) {
      print('❌ AI Error: $e');
      return 'AI service is currently unavailable. Please try again later.';
    }
  }

  /// 2️⃣ 🚀 Anlık Trendleri Çeken Fonksiyon (İyileştirilmiş)
  static Future<String> fetchCurrentTrends() async {
    try {
      // Bugünün tarihini alıyoruz
      String today = DateFormat('d MMMM yyyy').format(DateTime.now());
      
      // Gemini'ye özel bir soru soruyoruz
      final prompt = """
      Bugün tarih: $today.
      Şu an moda dünyasında (özellikle sokak modası ve günlük giyimde) öne çıkan en popüler 3 trend nedir?
      
      Cevabı SADECE şu formatta, tek cümle olarak ver:
      "Günün Trendleri: [Trend 1], [Trend 2], [Trend 3]"
      Başka hiçbir açıklama yapma.
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timeout');
        },
      );
      return response.text ?? "Trend verisi alınamadı.";
    } catch (e) {
      print('❌ Trend Fetch Error: $e');
      return "Classic styles, Neutral colors, Comfortable fits";
    }
  }
}