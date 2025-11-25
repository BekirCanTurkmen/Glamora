
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // ⚠️ Güvenlik notu: Gerçek yayında API key'i buraya doğrudan yazmamalısın.
  // Ama şimdilik test için sorun yok.
  static const String apiKey = "AIzaSyDZTV5brm7e8DBSgZqpJs9dKwneOBzXmHU";

  static final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );

  /// Basit metin sorusu sor
  static Future<String?> askGemini(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      return "AI Hatası: $e";
    }
  }
}