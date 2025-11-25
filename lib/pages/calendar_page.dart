import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/glamora_theme.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEvents();
  }

  /// 🔥 Firestore'dan Etkinlikleri Çekme
  Future<void> _fetchEvents() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users') // Koleksiyon adın 'glamora_users' ise burayı değiştir
        .doc(uid)
        .collection('planner')
        .get();

    final Map<DateTime, List<dynamic>> loadedEvents = {};

    for (var doc in snap.docs) {
      final data = doc.data();
      // data['date'] null gelirse hata vermesin diye kontrol
      if (data['date'] == null) continue;

      final date = (data['date'] as Timestamp).toDate();
      // Saat farkını yok et (Sadece Yıl-Ay-Gün)
      final dayKey = DateTime(date.year, date.month, date.day);

      if (loadedEvents[dayKey] == null) {
        loadedEvents[dayKey] = [];
      }
      
      // Doküman ID'sini de ekleyelim ki silerken lazım olur
      final eventData = data;
      eventData['id'] = doc.id; 
      
      loadedEvents[dayKey]!.add(eventData);
    }

    setState(() {
      _events = loadedEvents;
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  /// 👗 Gardıroptan Kıyafet Seçme Penceresi (YENİ ÖZELLİK)
  void _showWardrobePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Tam ekran boyu için izin ver
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6, // Ekranın %60'ı kadar açıl
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Gardırobundan Seç", 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: GlamoraColors.deepNavy
                  )
                ),
              ),
              Expanded(
                // Gardırop koleksiyonunu dinliyoruz
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('glamora_users') // DİKKAT: Senin wardrobe_page'de bu isim kullanılmıştı
                      .doc(uid)
                      .collection('wardrobe')
                      .orderBy('uploadedAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Gardırobun boş! Önce kıyafet yükle."));
                    }
                    
                    final docs = snapshot.data!.docs;

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final imageUrl = data['imageUrl'];
                        final category = data['category'] ?? 'Outfit';

                        return GestureDetector(
                          onTap: () async {
                            // Seçilen resmi takvime kaydet
                            await _savePlanToFirestore(imageUrl, category);
                            if (mounted) Navigator.pop(context); // Pencereyi kapat
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Seçimi Veritabanına Kaydetme
  Future<void> _savePlanToFirestore(String imageUrl, String note) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('planner')
        .add({
      'date': Timestamp.fromDate(_selectedDay!),
      'imageUrl': imageUrl, // Resim URL'si
      'note': note,         // Kategori adı
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Listeyi yenile ki ekranda hemen görünsün
    _fetchEvents(); 
  }
  
  /// Planı Silme Fonksiyonu
  Future<void> _deleteEvent(String docId) async {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('planner')
        .doc(docId)
        .delete();
      _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Outfit Calendar", style: TextStyle(color: GlamoraColors.deepNavy)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
      ),
      body: Column(
        children: [
          // TAKVİM BÖLÜMÜ
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            eventLoader: _getEventsForDay, 
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: GlamoraColors.creamBeige,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: GlamoraColors.deepNavy,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          const Divider(),
          
          // GÜNLÜK PLAN LİSTESİ
          Expanded(
            child: _getEventsForDay(_selectedDay!).isEmpty 
            ? const Center(child: Text("Bugün için plan yok."))
            : ListView(
              children: _getEventsForDay(_selectedDay!).map((event) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    // Eğer resim varsa göster, yoksa ikon göster
                    leading: event['imageUrl'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              event['imageUrl'], 
                              width: 50, 
                              height: 50, 
                              fit: BoxFit.cover
                            ),
                          )
                        : const Icon(Icons.checkroom, size: 40),
                    
                    title: Text(
                      event['note'] ?? 'Plan', 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: const Text("Planlanan Kıyafet"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                         if (event['id'] != null) {
                             _deleteEvent(event['id']);
                         }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      
      // EKLEME BUTONU
      floatingActionButton: FloatingActionButton(
        backgroundColor: GlamoraColors.deepNavy,
        onPressed: _showWardrobePicker, // ARTIK GARDIROBU AÇIYOR
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}