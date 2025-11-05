import 'package:flutter/material.dart';
import 'package:dolabim/pages/wardrobe_page.dart';
import 'package:dolabim/pages/trend_match_test_page.dart';
import '../theme/glamora_theme.dart';
import 'package:dolabim/pages/color_distribution_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/auth_page.dart';
import 'chat_list_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? city;
  String? temperature;
  String? description;
  bool loadingWeather = false;

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
    );
  }

  // 🔹 API'den hava durumu çek
  Future<void> fetchWeather(String cityName) async {
    setState(() {
      loadingWeather = true;
      city = cityName;
    });
    try {
      final url = Uri.parse('https://wttr.in/$cityName?format=j1');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = data['current_condition'][0]['temp_C'];
          description = data['current_condition'][0]['weatherDesc'][0]['value'];
        });
      }
    } catch (_) {}
    setState(() => loadingWeather = false);
  }

  // 🔹 Konumdan şehir bul
  Future<void> getCityFromLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final cityName = placemarks.first.locality ?? "Unknown";
      await fetchWeather(cityName);
    }
  }

  // 🔹 Popup menü
  void _showWeatherOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Hava durumu kaynağını seç",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.my_location),
                label: const Text("Konumdan bul"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlamoraColors.deepNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  getCityFromLocation();
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.location_city),
                label: const Text("Şehir seç"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlamoraColors.deepNavy,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: GlamoraColors.deepNavy),
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showCityPicker();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Şehir seçici (Dropdown popup)
  void _showCityPicker() {
    final List<String> cities = [
      'Istanbul',
      'Ankara',
      'Izmir',
      'Bursa',
      'Antalya',
      'Adana',
      'Konya',
      'Gaziantep',
      'Trabzon',
      'Eskisehir',
    ];

    showDialog(
      context: context,
      builder: (_) {
        String? selected = city ?? 'Istanbul';
        return AlertDialog(
          title: const Text("Şehir Seç"),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              return DropdownButton<String>(
                value: selected,
                isExpanded: true,
                items: cities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  setInnerState(() => selected = value);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                fetchWeather(selected!);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: GlamoraColors.deepNavy),
              child: const Text("Tamam", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _showWeatherOptions,
            child: _weatherCard(),
          ),
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
            desc: "Soft beige tones dominate this week’s top picks — simple yet timeless.",
          ),
        ],
      ),
    );
  }

  Widget _weatherCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFF6EFD9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: loadingWeather
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Text(
              city != null ? "📍 $city" : "Hava durumunu görmek için dokun",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: GlamoraColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            if (temperature != null)
              Text(
                "$temperature°C",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: GlamoraColors.deepNavy,
                ),
              ),
            if (description != null)
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
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
