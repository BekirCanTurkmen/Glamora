import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Glamora"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "👕 Hoş geldin, ${user?.email ?? "Kullanıcı"}!",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
