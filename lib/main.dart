import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/glamora_theme.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'splash/first_splash_screen.dart';
import 'splash/splash_after_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pygvjzgtzwlsdexscnye.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5Z3Zqemd0endsc2RleHNjbnllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxODQ2MjUsImV4cCI6MjA3NTc2MDYyNX0.CdpetuJdUB4zk_CDgaTVK34NCpHBp4lzC9YzRQ1UtrY',
  );

  runApp(const GlamoraApp());
}

class GlamoraApp extends StatelessWidget {
  const GlamoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glamora',
      debugShowCheckedModeBanner: false,
      theme: glamoraTheme,
      home: const AuthFlowController(),
    );
  }
}

/// 🔄 Tüm uygulama akışını yöneten widget
class AuthFlowController extends StatefulWidget {
  const AuthFlowController({super.key});

  @override
  State<AuthFlowController> createState() => _AuthFlowControllerState();
}

class _AuthFlowControllerState extends State<AuthFlowController> {
  bool _checkingSession = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _isLoggedIn = session != null;
      _checkingSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        backgroundColor: GlamoraColors.midnightBlue,
        body: Center(
          child: CircularProgressIndicator(color: GlamoraColors.creamBeige),
        ),
      );
    }

    // ✅ Login olmuşsa → SplashAfterLogin → HomePage
    if (_isLoggedIn) {
      return const SplashAfterLogin();
    }

    // 🚪 Login olmamışsa → FirstSplash
    return const FirstSplashScreen();
  }
}
