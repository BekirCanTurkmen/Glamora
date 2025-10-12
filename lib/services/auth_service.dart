import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 🔐 Email + Password ile giriş
  Future<String?> login(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// 🧾 Yeni kullanıcı kaydı
  Future<String?> register(String email, String password) async {
    try {
      await _client.auth.signUp(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// 🚪 Çıkış
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 👤 Şu anki kullanıcı UID
  String? get currentUserId => _client.auth.currentUser?.id;
}
