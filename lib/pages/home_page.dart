import 'package:flutter/material.dart';
import 'package:dolabim/pages/wardrobe_page.dart';
import '../theme/glamora_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Glamora Trends"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),

        // bu kısımda geçici olarak birkaç örnek trend kartı gösteriliyor
        children: [
          const Text(
            "Trending Styles",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ilk trend örneği
          Container(
            decoration: BoxDecoration(
              color: GlamoraColors.softWhite,
              borderRadius: BorderRadius.circular(16),
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
                          color: GlamoraColors.creamBeige,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Silky navy tones matched with warm beige accessories — modern classic look.",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ikinci trend örneği
          Container(
            decoration: BoxDecoration(
              color: GlamoraColors.softWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
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
                  child: Text(
                    "Soft beige tones dominating this week’s top picks.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // alt gezinme menüsü (trends + wardrobe)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: GlamoraColors.deepNavy,
        selectedItemColor: GlamoraColors.creamBeige,
        unselectedItemColor: Colors.white60,
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
}
