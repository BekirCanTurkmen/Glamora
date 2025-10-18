import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../splash/splash_after_login.dart';
import '../pages/auth_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase oturum kontrolü yapılıyor
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF6EFD9)),
            ),
          );
        }

        // Kullanıcı zaten giriş yaptıysa SplashAfterLogin'e yönlendir
        if (snapshot.hasData) {
          return const SplashAfterLogin();
        }

        // Kullanıcı giriş yapmamışsa AuthPage aç
        return const AuthPage();
      },
    );
  }
}
