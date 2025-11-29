import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart'; // Tarih formatı için (Eğer hata verirse: flutter pub add intl)

class AiService {
  // Senin API Key'in
  static const String apiKey = "AIzaSyDZTV5brm7e8DBSgZqpJs9dKwneOBzXmHU";

  // Modeli burada tanımlıyoruz
  static final model = GenerativeModel(
    model: 'gemini-2.5-flash', 
    apiKey: apiKey,
  );

  /// 1️⃣ Normal Sohbet Fonksiyonu (Mevcut olan)
  static Future<String?> askGemini(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      return "AI Hatası: $e";
    }
  }

  /// 2️⃣ 🚀 YENİ: Anlık Trendleri Çeken Fonksiyon
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
      final response = await model.generateContent(content);
      return response.text ?? "Trend verisi alınamadı.";
    } catch (e) {
      return "Trendler şu an yüklenemiyor.";
    }
  }
}