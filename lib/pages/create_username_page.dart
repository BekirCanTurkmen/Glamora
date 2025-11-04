import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/glamora_theme.dart';

class CreateUsernamePage extends StatefulWidget {
  const CreateUsernamePage({super.key});

  @override
  State<CreateUsernamePage> createState() => _CreateUsernamePageState();
}

class _CreateUsernamePageState extends State<CreateUsernamePage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> _saveUsername() async {
    final username = _controller.text.trim().toLowerCase();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir kullanıcı adı girin.")),
      );
      return;
    }

    setState(() => _loading = true);

    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser!;
    final usersRef = firestore.collection('glamora_users');

    // Aynı kullanıcı adı var mı kontrol et
    final existing =
    await usersRef.where('username', isEqualTo: username).get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bu kullanıcı adı zaten alınmış.")),
      );
      setState(() => _loading = false);
      return;
    }

    // Firestore'a kaydet
    await usersRef.doc(currentUser.uid).set({
      'username': username,
      'createdAt': DateTime.now(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kullanıcı adınız kaydedildi ✅")),
    );

    setState(() => _loading = false);
    Navigator.pop(context, username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ açık arka plan
      appBar: AppBar(
        backgroundColor: GlamoraColors.deepNavy,
        centerTitle: true,
        title: const Text(
          "Kullanıcı Adı Oluştur",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // 🪞 Glamora logosu
            Image.asset(
              'assets/images/glamora_logo.png',
              width: 130,
              height: 80,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 30),

            const Text(
              "Mesajlaşma özelliğini kullanmak için\nbenzersiz bir kullanıcı adı oluşturun.",
              style: TextStyle(
                fontSize: 16,
                color: GlamoraColors.deepNavy,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // 🔹 Kullanıcı adı TextField
            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              cursorColor: GlamoraColors.deepNavy,
              style: const TextStyle(
                color: GlamoraColors.deepNavy,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "örnek: glamora_mer",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: GlamoraColors.softWhite,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: GlamoraColors.deepNavy,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: GlamoraColors.deepNavy,
                    width: 1.8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 🔹 Kaydet butonu
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlamoraColors.deepNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Kaydet",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
