import 'package:flutter/material.dart';
import 'package:dolabim/pages/chat_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // JSON decode için
import '../pages/auth_page.dart';
import '../theme/glamora_theme.dart';
import '../widgets/weather_card.dart';
import 'package:dolabim/pages/ai_chat_page.dart';
import 'package:dolabim/pages/wardrobe_page.dart';
import 'package:dolabim/pages/trend_match_test_page.dart';
import 'package:dolabim/pages/calendar_page.dart';
import '../services/ai_service.dart';
import 'package:dolabim/pages/photo_uploader.dart';
import 'package:dolabim/pages/outfit_result_page.dart';
import 'package:dolabim/pages/winter_trends_page.dart';
import 'package:dolabim/pages/spring_trends_page.dart';
import 'package:dolabim/pages/social_feed_page.dart';
import 'package:dolabim/pages/style_analytics_page.dart';
import 'package:dolabim/pages/style_coach_page.dart';
import 'package:dolabim/pages/trend_matcher_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  
  // ⏳ YÜKLENİYOR DURUMU (Progress Bar Kontrolü)
  bool _isGenerating = false; 

  // 🎭 MOD SİSTEMİ
  String _selectedMoodLabel = "Happy";
  
  final List<Map<String, dynamic>> _moods = [
    {"label": "Happy", "icon": Icons.sentiment_satisfied_alt_rounded},
    {"label": "Business", "icon": Icons.business_center_rounded},
    {"label": "Casual", "icon": Icons.local_cafe_rounded},
    {"label": "Party", "icon": Icons.celebration_rounded},
    {"label": "Lazy", "icon": Icons.weekend_rounded},
    {"label": "Date", "icon": Icons.favorite_rounded},
  ];

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  // 🚀 SİHİRLİ FONKSİYON (Loading State Eklenmiş)
  Future<void> _generateSmartOutfit(BuildContext context) async {
    // 1. Yükleniyor durumunu başlat
    setState(() {
      _isGenerating = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isGenerating = false);
      return;
    }

    try {
      // 2. Trendleri Çek
      String liveTrendInfo = await AiService.fetchCurrentTrends();

      // 3. Gardırop Verisini Çek
      List<String> inventoryList = [];
      
      final snap = await FirebaseFirestore.instance
          .collection('glamora_users') 
          .doc(uid)
          .collection('wardrobe')
          .get();

      if (snap.docs.isNotEmpty) {
        inventoryList = snap.docs.map((d) {
          final data = d.data();
          final category = data['category'] ?? 'Kategori Yok';
          final color = data['colorLabel'] ?? 'Renk Yok';
          final brand = data['brand'] ?? '';
          return "ID: ${d.id}, Kategori: $category, Renk: $color, Marka: $brand";
        }).toList();
      }

      if (inventoryList.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("HATA: Dolap boş! Önce kıyafet ekleyin.")),
          );
        }
        // İşlem bitti, loading kapat
        setState(() => _isGenerating = false);
        return;
      }

      String weatherContext = "Hava: Parçalı Bulutlu, 18°C";
      String moodContext = "Mod: $_selectedMoodLabel";

      // 4. Prompt Hazırla
      String systemPrompt = """
      **ROL:**
      Sen, JSON formatında yanıt veren gelişmiş bir "Kişisel Stilist API"sisin.
      
      **GÖREV:**
      Aşağıdaki envanteri analiz et ve kurallara uyarak JSON üret.
      
      **VERİLER:**
      - Trendler: $liveTrendInfo
      - Durum: $weatherContext, $moodContext
      - ENVANTER LİSTESİ:
      ${inventoryList.join("\n")}

      **KURALLAR:**
      1. SADECE geçerli bir JSON objesi döndür. Markdown (```json) kullanma.
      2. "selected_item_id" ve "alternative_item_id" alanlarına ENVANTER LİSTESİNDEKİ "ID" değerlerini birebir kopyala.
      3. Head, Top, Bottom, Shoes ve Accessory (varsa) için slot oluştur.
      
      **İSTENEN JSON FORMATI:**
      {
        "outfit_summary": "Kombinin kısa, havalı başlığı",
        "total_style_score": "10 üzerinden uyum puanı",
        "calendar_entry": {
          "title": "Bugünün Kombini",
          "description": "Detaylar..."
        },
        "items": [
          {
            "slot": "Top",
            "selected_item_id": "BURAYA_ENVANTERDEN_ID_GELMELI",
            "item_name": "Kıyafetin Adı",
            "reason": "Sebebi...",
            "alternative_item_id": "BURAYA_ALTERNATIF_ID_GELMELI"
          }
        ]
      }
      """;

      // 5. AI'ya Sor
      String? jsonResponse = await AiService.askGemini(systemPrompt);
      
      if (jsonResponse != null && jsonResponse.isNotEmpty) {
        try {
          // Markdown wrapper'larını temizle
          jsonResponse = jsonResponse.replaceAll('```json', '').replaceAll('```', '').trim();
          
          // ✅ JSON PARSE KONTROLÜ
          final Map<String, dynamic> parsed = jsonDecode(jsonResponse);
          
          // ✅ SCHEMA VALİDASYONU
          if (!parsed.containsKey('items') || !parsed.containsKey('outfit_summary')) {
            throw FormatException('AI response missing required fields');
          }
          
          if (parsed['items'] == null || (parsed['items'] as List).isEmpty) {
            throw FormatException('No outfit items returned');
          }

          // ✅ BAŞARILI - Navigate
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OutfitResultPage(jsonResult: jsonResponse!, userId: uid),
              ),
            );
          }
        } on FormatException catch (e) {
          // JSON parse hatası
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("AI yanıtı beklenenden farklı geldi. Lütfen tekrar deneyin."),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'TEKRAR DENE',
                  textColor: Colors.white,
                  onPressed: () => _generateSmartOutfit(context),
                ),
              ),
            );
          }
          print('❌ JSON Parse Error: $e');
        } catch (e) {
          // Diğer hatalar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Beklenmeyen bir hata oluştu.")),
            );
          }
          print('❌ Unexpected Error: $e');
        }
      } else {
        // AI yanıt vermedi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("AI şu anda yanıt veremiyor. Lütfen daha sonra tekrar deneyin.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bir hata oluştu: $e")));
      }
    } finally {
      // 6. İşlem bitti (Başarılı veya Hatalı), Loading'i kapat
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _onNavTap(int index) {
    setState(() => selectedIndex = index);
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WardrobePage()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TrendMatcherPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage()));
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
          "Glamora",
          style: TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore_rounded, color: GlamoraColors.deepNavy),
            tooltip: 'Social Feed',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialFeedPage())),
          ),
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: GlamoraColors.deepNavy),
            tooltip: 'Style Analytics',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StyleAnalyticsPage())),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: GlamoraColors.deepNavy),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListPage())),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: GlamoraColors.deepNavy),
            tooltip: 'AI Style Coach',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StyleCoachPage())),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: GlamoraColors.deepNavy),
            color: Colors.white,
            onSelected: (v) async { if (v == 'logout') await _logout(context); },
            itemBuilder: (_) => [const PopupMenuItem(value: 'logout', child: Text("Log Out"))],
          ),
        ],
      ),
      
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const WeatherCard(),
          
          const SizedBox(height: 30),
          
          // --- MOOD SEÇİCİ ---
          Text(
            "How are you feeling?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: GlamoraColors.deepNavy.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 90, 
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _moods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final mood = _moods[index];
                final isSelected = _selectedMoodLabel == mood['label'];
                
                return GestureDetector(
                  onTap: () {
                    // Yüklenirken mod değiştirmeyi engelleyelim
                    if (!_isGenerating) {
                      setState(() => _selectedMoodLabel = mood['label']);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 75,
                    decoration: BoxDecoration(
                      color: isSelected ? GlamoraColors.deepNavy : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.shade200,
                        width: 1.5
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: GlamoraColors.deepNavy.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          mood['icon'],
                          color: isSelected ? Colors.white : GlamoraColors.deepNavy,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // --- 🪄 SİHİRLİ BUTON (YÜKLENİYOR ANİMASYONLU) ---
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isGenerating ? Colors.grey.shade300 : GlamoraColors.deepNavy,
                elevation: _isGenerating ? 0 : 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              // Eğer yükleniyorsa butona basılamaz (null)
              onPressed: _isGenerating ? null : () => _generateSmartOutfit(context),
              child: _isGenerating 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(
                          color: GlamoraColors.deepNavy, 
                          strokeWidth: 2.5
                        )
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Analyzing Wardrobe...", // Yüklenirken yazan yazı
                        style: TextStyle(fontSize: 16, color: GlamoraColors.deepNavy, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : Row( // Normal Durum
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.auto_awesome, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        "Generate Daily Outfit",
                        style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            "Trending Now",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GlamoraColors.deepNavy,
            ),
          ),
          const SizedBox(height: 16),

// HERO (MODA VİTRİNİ)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WinterTrendsPage(),
                ),
              );
            },
            child: _trendCard(
              image: 'assets/images/glamora_logo.png',
              title: "Winter Trends",
              desc: "Key winter colors and styles shaping this season.",
            ),
          ),


          const SizedBox(height: 24),

// EDITORIAL (DERGİ STİLİ)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SpringTrendsPage(),
                ),
              );
            },
            child: _trendCard(
              image: 'assets/images/glamora_harf_logo.png',
              title: "Spring Trends",
              desc: "A calm spring palette shaping this season.",
            ),
          ),


        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhotoUploader())),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: GlamoraColors.deepNavy, size: 30),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: GlamoraColors.deepNavy,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: selectedIndex,
        onTap: _onNavTap,
        showUnselectedLabels: false,
        elevation: 20,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checkroom_rounded), label: "Wardrobe"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_mosaic_rounded), label: "Trends"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: "Calendar"),
        ],
      ),
    );
  }

  Widget _trendCard({
    required String image,
    required String title,
    required String desc,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // 🔹 GÖRSEL (VİTRİN)
          Image.asset(
            image,
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // 🔹 KARARTI (MODA / EDITORIAL HİSSİ)
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.65),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 🔹 YAZILAR GÖRSEL ÜSTÜNDE
          Positioned(
            left: 20,
            bottom: 22,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }Widget _trendHeroCard({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.asset(
            image,
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.65),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 24,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendEditorialCard({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GlamoraColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}