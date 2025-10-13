import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


/// Uygulamadaki tüm kullanıcı giriş, kayıt ve şifre sıfırlama işlemlerini yönetir.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Yeni kullanıcı kaydı (Register)
  /// Kullanıcı e-posta ve şifre ile kayıt olur, ardından Firestore'a kaydedilir.
  Future<String?> register(String email, String password) async {
    try {
      // Firebase Authentication'da kullanıcı oluştur
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'da kullanıcı bilgilerini sakla
      await FirebaseFirestore.instance
          .collection('glamora_users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'createdAt': DateTime.now(),
        'uid': userCredential.user!.uid,
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return "Your password is too weak.";
        case 'email-already-in-use':
          return "This email is already registered.";
        case 'invalid-email':
          return "Please enter a valid email address.";
        default:
          return e.message ?? "Registration failed.";
      }
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  ///  Kullanıcı girişi (Login)
  /// Email ve şifre ile giriş yapar, hata durumlarını yakalar.
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No user found for this email.";
        case 'wrong-password':
          return "Incorrect password.";
        case 'invalid-email':
          return "Invalid email format.";
        default:
          return e.message ?? "Login failed.";
      }
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  ///  Şifre sıfırlama (Forgot Password)
  /// Kullanıcı e-posta adresini girer, Firebase sıfırlama linkini gönderir.
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No user found with this email.";
        case 'invalid-email':
          return "Invalid email address.";
        default:
          return e.message ?? "Password reset failed.";
      }
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  ///  Kullanıcı çıkış işlemi
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// 🔹 Aktif kullanıcı bilgisi
  User? get currentUser => _auth.currentUser;

  /// 🔹 Kullanıcının giriş yapıp yapmadığını kontrol et
  bool get isLoggedIn => _auth.currentUser != null;
}
