import 'package:dolabim/pages/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'theme/glamora_theme.dart';
import 'splash/first_splash_screen.dart';

Future<void> main() async {
  // 1. Flutter bindings başlat
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Environment variables yükle (.env dosyası)
  await dotenv.load(fileName: ".env");

  // 3. Firebase başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Firebase Crashlytics başlat
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  
  // 5. Flutter framework hatalarını Crashlytics'e gönder
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 6. Async hataları yakala
  runZonedGuarded(() {
    runApp(const GlamoraApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  });
}

class GlamoraApp extends StatelessWidget {
  const GlamoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glamora',


      theme: glamoraTheme,


      home: const AuthGate(),
    );
  }
}
