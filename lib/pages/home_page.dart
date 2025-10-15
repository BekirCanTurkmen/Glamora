import 'package:flutter/material.dart';
import 'package:dolabim/pages/wardrobe_page.dart';
import 'package:dolabim/pages/trend_match_test_page.dart';
import '../theme/glamora_theme.dart';
import 'package:dolabim/pages/color_distribution_page.dart';

// ↓ Functions için gerekli paketler
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

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

        // ✅ İKİNCİ KODDAN EKLENEN AKSİYONLAR
        actions: [
          // Trend Match test sayfası
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

          // 🎨 Renk Dağılımı Grafiği
          IconButton(
            tooltip: 'Renk Dağılımı Grafiği',
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              // Demo: örnek görseller, kendi dolabındaki veriye göre düzenleyebilirsin
              final demoItems = [
                WardrobeItem(image: const AssetImage('assets/images/glamora_logo.png')),
                WardrobeItem(image: const AssetImage('Glamora/assets/images/ggnjknsm.5kg_IMG_01_8683791425782.jpg')),
              ];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ColorDistributionPage(items: demoItems),
                ),
              );
            },
          ),

          // Functions menüsü (fetchTrendsNow + suggestOutfits)
          PopupMenuButton<String>(
            onSelected: (v) async {
              try {
                if (v == 'fetchTrends') {
                  // TODO: <REGION> ve <PROJECT_ID> değerlerini kendi Functions URL'inden kopyala
                  final url = Uri.parse(
                    'https://<REGION>-<PROJECT_ID>.cloudfunctions.net/fetchTrendsNow',
                  );
                  final r = await http.get(url);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('fetchTrendsNow: ${r.statusCode}')),
                  );
                } else if (v == 'suggest') {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Önce giriş yapmalısın')),
                    );
                    return;
                  }

                  final callable = FirebaseFunctions.instance.httpsCallable('suggestOutfits');
                  final res = await callable.call({'limit': 6});
                  final List combos = List.from(res.data);

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Öneriler'),
                      content: Text(
                        combos.isEmpty
                            ? 'Öneri yok'
                            : combos.map((e) => e['trend']).join(', '),
                      ),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hata: $e')),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'fetchTrends',
                child: Text('Trendleri Doldur (Dev)'),
              ),
              PopupMenuItem(
                value: 'suggest',
                child: Text('Kombin Öner (Callable)'),
              ),
            ],
          ),
        ],
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
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    'assets/images/glamora_harf_logo.png',
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
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

      // 🔸 alt gezinme menüsü (ilk koddaki açık tema korunur)
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
