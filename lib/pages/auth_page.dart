import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../pages/forgot_password_page.dart';
import '../splash/splash_after_login.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  // 🔹 Kullanıcı Firestore'da kayıtlı değilse ekle
  Future<void> _saveUserDataIfNotExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
    FirebaseFirestore.instance.collection('glamora_users').doc(user.uid);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ User added to glamora_users: ${user.email}');
    } else {
      print('ℹ️ User already exists: ${user.email}');
    }
  }

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);
    String? result;

    if (isLogin) {
      result = await _authService.login(email, password);
    } else {
      result = await _authService.register(email, password);
    }

    setState(() => isLoading = false);

    if (result == "success") {
      // ✅ Firestore'da kullanıcıyı kaydet
      await _saveUserDataIfNotExists();

      // ✅ Giriş veya kayıt başarılı → SplashAfterLogin ekranına git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashAfterLogin()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1739), Color(0xFF13224F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Glamora",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFFF6EFD9),
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 40),

                // 📨 Email field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    labelText: "Email",
                    labelStyle: const TextStyle(
                        color: Color(0xFFF6EFD9), fontSize: 16),
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFFF6EFD9)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFF6EFD9), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFF6EFD9)),
                ),
                const SizedBox(height: 20),

                // 🔑 Password field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    labelText: "Password",
                    labelStyle: const TextStyle(
                        color: Color(0xFFF6EFD9), fontSize: 16),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFFF6EFD9)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFFF6EFD9), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFF6EFD9)),
                ),
                const SizedBox(height: 15),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const ForgotPasswordPage()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFFF6EFD9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🟤 Login/Register button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6EFD9),
                      foregroundColor: const Color(0xFF0B1739),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                        color: Color(0xFF0B1739))
                        : Text(isLogin ? "Login" : "Register"),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔄 Toggle login/register
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? "Don’t have an account? Register"
                        : "Already have an account? Login",
                    style: const TextStyle(
                      color: Color(0xFFF6EFD9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
