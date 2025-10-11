import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Kullanıcı Kaydı (Register)
  Future<String?> register(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'a kullanıcı bilgisi ekle
      await FirebaseFirestore.instance
          .collection('glamora_users') // değişti
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'createdAt': DateTime.now(),
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "Password too weak";
      } else if (e.code == 'email-already-in-use') {
        return "Email already registered";
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  // 🔹 Kullanıcı Girişi (Login)
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "User not found";
      } else if (e.code == 'wrong-password') {
        return "Incorrect password";
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  // 🔹 Çıkış Yapma
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔹 Aktif Kullanıcı
  User? get currentUser => _auth.currentUser;
}
