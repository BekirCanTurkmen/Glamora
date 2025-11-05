import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String? city;
  String? country;
  String? temperature;
  String? description;
  bool loading = false;

  // 🌤️ Hava durumu çek
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
      } else {
        temperature = null;
        description = null;
      }
    } catch (_) {
      temperature = null;
      description = null;
    }

    setState(() => loading = false);
  }

  // 📍 Konumdan şehir + ülke bul
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
      final cityName = placemark.locality ?? "Unknown";
      final countryName = placemark.country ?? "";
      setState(() {
        city = cityName;
        country = countryName;
      });
      await fetchWeather(cityName);
    }
  }

  // 🔹 Alt popup: konum mu, şehir mi?
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
                  backgroundColor: Colors.blueGrey[900],
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
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueGrey[900],
                  side: const BorderSide(color: Colors.blueGrey),
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

  // 🔹 Şehir seçici (Türkiye şehirleri)
  void _showCityPicker() {
    final List<String> cities = [
      'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Aksaray', 'Amasya',
      'Ankara', 'Antalya', 'Ardahan', 'Artvin', 'Aydın', 'Balıkesir', 'Bartın',
      'Batman', 'Bayburt', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur',
      'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır',
      'Düzce', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir',
      'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari', 'Hatay', 'Iğdır',
      'Isparta', 'İstanbul', 'İzmir', 'Kahramanmaraş', 'Karabük', 'Karaman',
      'Kars', 'Kastamonu', 'Kayseri', 'Kırıkkale', 'Kırklareli', 'Kırşehir',
      'Kilis', 'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Mardin',
      'Mersin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu', 'Osmaniye', 'Rize',
      'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Şanlıurfa', 'Şırnak',
      'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Uşak', 'Van', 'Yalova',
      'Yozgat', 'Zonguldak'
    ];

    showDialog(
      context: context,
      builder: (_) {
        String selected = (city != null && cities.contains(city))
            ? city!
            : 'İstanbul';

        return AlertDialog(
          title: const Text("Şehir Seç"),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              return DropdownButton<String>(
                value: selected,
                isExpanded: true,
                items: cities
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                ))
                    .toList(),
                onChanged: (value) {
                  setInnerState(() => selected = value!);
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
                setState(() {
                  country = "Türkiye";
                });
                fetchWeather(selected);
              },
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[900]),
              child: const Text("Tamam", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showWeatherOptions,
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFFF6EFD9),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (city != null)
                Text(
                  '📍 $city${country != null ? ', $country' : ''}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                )
              else
                const Text(
                  'Hava durumunu görmek için dokun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              const SizedBox(height: 10),
              if (temperature != null)
                Text(
                  '$temperature°C',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
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
