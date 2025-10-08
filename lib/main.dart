import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Kıyafet Testi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FirestoreTestPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  State<FirestoreTestPage> createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  String _status = "Firestore’a veri ekleniyor...";

  @override
  void initState() {
    super.initState();
    _addClothesToFirestore();
  }

  Future<void> _addClothesToFirestore() async {
    try {
      // Firestore koleksiyonuna referans
      final clothesCollection = FirebaseFirestore.instance.collection(
        'clothes',
      );

      // 5 adet kıyafet ismi
      final clothes = [
        {'name': 'Beyaz Tişört'},
        {'name': 'Kot Pantolon'},
        {'name': 'Siyah Ceket'},
        {'name': 'Kırmızı Elbise'},
        {'name': 'Gri Hoodie'},
      ];

      // Her birini Firestore’a ekle
      for (var cloth in clothes) {
        await clothesCollection.add(cloth);
      }

      setState(() {
        _status = "✅ 5 kıyafet ismi başarıyla eklendi!";
      });

      print("✅ Firestore’a 5 kıyafet eklendi!");
    } catch (e) {
      setState(() {
        _status = "❌ Hata oluştu: $e";
      });
      print("❌ Firestore hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Firestore Test")),
      body: Center(
        child: Text(
          _status,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
