import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/glamora_theme.dart';
import 'pages/auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌐 Supabase bağlantısı
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
      home: const AuthPage(),
    );
  }
}
