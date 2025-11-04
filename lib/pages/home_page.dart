import 'package:flutter/material.dart';
import 'package:dolabim/pages/wardrobe_page.dart';
import 'package:dolabim/pages/trend_match_test_page.dart';
import '../theme/glamora_theme.dart';
import 'package:dolabim/pages/color_distribution_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/auth_page.dart';
import 'chat_list_page.dart'; // ✅ yeni liste ekranını dahil ettik

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Glamora Trends",
          style: TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
        actions: [
          IconButton(
            tooltip: 'Trend Match (Test)',
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrendMatchTestPage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Renk Dağılımı Grafiği',
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              final demoItems = [
                WardrobeItem(image: const AssetImage('assets/images/glamora_logo.png')),
                WardrobeItem(image: const AssetImage('assets/images/glamora_harf_logo.png')),
              ];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ColorDistributionPage(items: demoItems),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Mesajlaşma',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListPage()),
              );
            },
          ),
          PopupMenuButton<String>(
            color: const Color(0xFFF6EFD9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (v) async {
              if (v == 'logout') await _logout(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFFB33A3A)),
                    SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: Color(0xFFB33A3A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // 🔹 Ana içerik (örnek trend kartları)
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Trending Styles",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: GlamoraColors.deepNavy,
            ),
          ),
          const SizedBox(height: 16),
          _trendCard(
            image: 'assets/images/glamora_logo.png',
            title: "Midnight Elegance",
            desc:
            "Silky navy tones matched with warm beige accessories — a modern classic look.",
          ),
          const SizedBox(height: 24),
          _trendCard(
            image: 'assets/images/glamora_harf_logo.png',
            title: "Soft Beige Harmony",
            desc:
            "Soft beige tones dominate this week’s top picks — simple yet timeless.",
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: GlamoraColors.deepNavy,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trends"),
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: "Wardrobe"),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WardrobePage()),
            );
          }
        },
      ),
    );
  }

  Widget _trendCard({required String image, required String title, required String desc}) {
    return Container(
      decoration: BoxDecoration(
        color: GlamoraColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GlamoraColors.deepNavy.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Image.asset(image, fit: BoxFit.cover, height: 200, width: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: GlamoraColors.deepNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 6),
                Text(desc,
                    style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
