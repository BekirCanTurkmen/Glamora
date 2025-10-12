import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/glamora_theme.dart';
import '../services/auth_service.dart';
import 'wardrobe_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ Eğer kullanıcı zaten giriş yaptıysa direkt yönlendir
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WardrobePage()),
        );
      });
    }
  }

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);
    String? result;

    if (isLogin) {
      result = await _authService.login(email, password);
    } else {
      result = await _authService.register(email, password);
      // 🔑 Kayıt sonrası otomatik giriş
      if (result == null) {
        result = await _authService.login(email, password);
      }
    }

    setState(() => isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WardrobePage()),
      );
    } else {
      _showSnack(result);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: GlamoraColors.midnightBlue)),
        backgroundColor: GlamoraColors.creamBeige,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlamoraColors.midnightBlue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Glamora",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: GlamoraColors.creamBeige,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // ✉️ Email Field
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlamoraColors.creamBeige),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: GlamoraColors.creamBeige, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 🔑 Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlamoraColors.creamBeige),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: GlamoraColors.creamBeige, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 🚀 Login/Register Button
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlamoraColors.creamBeige,
                    foregroundColor: GlamoraColors.midnightBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: GlamoraColors.midnightBlue,
                      strokeWidth: 2.4,
                    ),
                  )
                      : Text(isLogin ? "Login" : "Register"),
                ),

                const SizedBox(height: 14),

                // 🔁 Switch Mode (Login <-> Register)
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? "Don't have an account? Register"
                        : "Already have an account? Login",
                    style: const TextStyle(color: Colors.white70),
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
