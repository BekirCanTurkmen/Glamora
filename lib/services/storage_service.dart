import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  /// ☁ Upload image to Supabase Storage
  Future<String?> uploadImage(File file, String userId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await _client.storage.from('wardrobe').upload('$userId/$fileName', file);
      final publicUrl = _client.storage.from('wardrobe').getPublicUrl('$userId/$fileName');
      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  /// 🧩 Save image record (metadata)
  Future<void> saveImageRecord({
    required String userId,
    required String imageUrl,
    String? category,
  }) async {
    try {
      await _client.from('wardrobe').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'category': category ?? 'Uncategorized',
        'created_at': DateTime.now().toIso8601String(),
      });
      print('✅ Image record saved to DB');
    } catch (e) {
      print('DB insert error: $e');
    }
  }
}
