import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/first_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GlamoraApp());
}

class GlamoraApp extends StatelessWidget {
  const GlamoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glamora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC8A25D)),
        useMaterial3: true,
      ),
      home: const FirstSplashScreen(), // ✨ İlk açılışta gösterilecek
    );
  }
}
