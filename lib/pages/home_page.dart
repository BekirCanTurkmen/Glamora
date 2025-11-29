import 'package:flutter/material.dart';
import 'package:dolabim/pages/chat_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/auth_page.dart';
import '../theme/glamora_theme.dart';
import '../widgets/weather_card.dart';
import 'package:dolabim/pages/ai_chat_page.dart';

import 'package:dolabim/pages/wardrobe_page.dart';
import 'package:dolabim/pages/trend_match_test_page.dart';
import 'package:dolabim/pages/calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0; // 🔥 ASLA NEGATİF/100 OLMAYACAK

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
    );
  }

  void _onNavTap(int index) {
    setState(() => selectedIndex = index);

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WardrobePage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TrendMatchTestPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CalendarPage()),
      );
    }
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
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiChatPage()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') await _logout(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'logout',
                  child: Text("Log Out", style: TextStyle(color: Colors.red)))
            ],
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const WeatherCard(),
          const SizedBox(height: 20),
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
        backgroundColor: const Color(0xFFF6EFD9),
        selectedItemColor: Colors.grey.shade600,    // 🔥 HomePage seçili görünmesin
        unselectedItemColor: Colors.grey.shade600,  // 🔥 Tamamen eşit renk

        currentIndex: selectedIndex, // 🔥 GARANTİ 0–2 ARASI
        onTap: _onNavTap,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            label: "Wardrobe",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style_outlined),
            label: "Trend Match",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "Calendar",
          ),
        ],
      ),
    );
  }

  Widget _trendCard({
    required String image,
    required String title,
    required String desc,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: GlamoraColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GlamoraColors.deepNavy.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(image, height: 200, fit: BoxFit.cover),
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
                    style: const TextStyle(color: Colors.black87, fontSize: 14))
              ],
            ),
          )
        ],
      ),
    );
  }
}
