import 'package:flutter/material.dart';
import 'package:dolabim/pages/wardrobe_page.dart';
import '../theme/glamora_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ açık arka plan

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Glamora Trends",
          style: TextStyle(
            color: GlamoraColors.deepNavy, // ✅ koyu lacivert yazı
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Trending Styles",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: GlamoraColors.deepNavy, // ✅ lacivert başlık
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 1. Trend kartı
          Container(
            decoration: BoxDecoration(
              color: GlamoraColors.softWhite, // ✅ soft gri arka plan
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
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/glamora_logo.png',
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Midnight Elegance",
                        style: TextStyle(
                          color: GlamoraColors.deepNavy, // ✅ lacivert başlık
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Silky navy tones matched with warm beige accessories — a modern classic look.",
                        style: TextStyle(
                          color: Colors.black87, // ✅ açık gri metin
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🔹 2. Trend kartı
          Container(
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/glamora_harf_logo.png',
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    "Soft beige tones dominate this week’s top picks.",
                    style: TextStyle(
                      color: GlamoraColors.deepNavy, // ✅ lacivert yazı
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 🔸 alt gezinme menüsü
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // ✅ beyaz alt bar
        selectedItemColor: GlamoraColors.deepNavy, // ✅ seçili lacivert
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Trends",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: "Wardrobe",
          ),
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
}
