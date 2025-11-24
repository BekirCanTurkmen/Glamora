import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../theme/glamora_theme.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String? city;           // UI’da gösterilen şehir
  String? temperature;
  String? description;
  bool loading = false;

  final List<String> cities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Aksaray', 'Amasya', 'Ankara', 'Antalya',
    'Ardahan', 'Artvin', 'Aydın', 'Balıkesir', 'Bartın', 'Batman', 'Bayburt', 'Bilecik',
    'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli',
    'Diyarbakır', 'Düzce', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep',
    'Giresun', 'Gümüşhane', 'Hakkari', 'Hatay', 'Iğdır', 'Isparta', 'İstanbul', 'İzmir',
    'Kahramanmaraş', 'Karabük', 'Karaman', 'Kars', 'Kastamonu', 'Kayseri', 'Kırıkkale',
    'Kırklareli', 'Kırşehir', 'Kilis', 'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa',
    'Mardin', 'Mersin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu', 'Osmaniye', 'Rize',
    'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Şanlıurfa', 'Şırnak', 'Tekirdağ',
    'Tokat', 'Trabzon', 'Tunceli', 'Uşak', 'Van', 'Yalova', 'Yozgat', 'Zonguldak'
  ];

  // 🌤️ API'den hava durumu çek
  Future<void> fetchWeather(String cityName) async {
    setState(() {
      loading = true;
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
    setState(() => loading = false);
  }

  // 📍 Konumdan şehir bul ve ekranda göster
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
      final placemark = placemarks.first;
      final cityName = placemark.locality ?? placemark.administrativeArea ?? "Unknown";
      final countryName = placemark.country ?? "";

      // 🏙️ Şehri UI’da hemen gösterelim
      setState(() {
        city = "$cityName${countryName.isNotEmpty ? ", $countryName" : ""}";
      });

      // ☁️ Hava durumu bilgisini de çekelim
      await fetchWeather(cityName);
    }
  }


  // 🔹 Şehir seçici (tam güvenli)
  void _showCityPicker() {
    String? selected; // null olabilir, hata vermez

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Select City"),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              return DropdownButton<String>(
                value: cities.contains(selected) ? selected : null,
                hint: const Text("Select a city"),
                isExpanded: true,
                items: cities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setInnerState(() => selected = value),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selected == null) return;
                Navigator.pop(context);
                fetchWeather(selected!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlamoraColors.deepNavy,
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Alt seçenek popup’ı
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
                "Select Weather Source",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.my_location),
                label: const Text("Use Current Location"),
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
                label: const Text("Select City"),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showWeatherOptions,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFFF6EFD9),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Text(
                city != null
                    ? "📍 $city"
                    : "Tap to check the weather",
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
      ),
    );
  }
}
