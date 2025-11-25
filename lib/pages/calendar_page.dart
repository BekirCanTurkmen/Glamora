import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/glamora_theme.dart';
import 'package:intl/intl.dart';

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

    // Basitlik için tüm planları çekiyoruz. İlerde ay bazlı filtreleyebilirsin.
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('planner')
        .get();

    final Map<DateTime, List<dynamic>> loadedEvents = {};

    for (var doc in snap.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      // Tarihi sadece Yıl-Ay-Gün olarak normalleştir (saat farkını yok et)
      final dayKey = DateTime(date.year, date.month, date.day);

      if (loadedEvents[dayKey] == null) {
        loadedEvents[dayKey] = [];
      }
      loadedEvents[dayKey]!.add(data);
    }

    setState(() {
      _events = loadedEvents;
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Normalizasyon: Saat bilgisini sıfırla
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  /// ➕ Yeni Plan Ekleme Dialogu
  void _showAddDialog() {
    final TextEditingController noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Plan for ${DateFormat('MMM d').format(_selectedDay!)}"),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(hintText: "Örn: Mavi Gömlek & Jean"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GlamoraColors.deepNavy),
            onPressed: () async {
              if (noteController.text.isEmpty) return;
              final uid = FirebaseAuth.instance.currentUser!.uid;
              
              // Firestore'a kaydet
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('planner')
                  .add({
                'date': Timestamp.fromDate(_selectedDay!),
                'note': noteController.text,
                'createdAt': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
              _fetchEvents(); // Listeyi yenile
            },
            child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            eventLoader: _getEventsForDay, // Noktaları gösterir
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
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay!).map((event) {
                return ListTile(
                  leading: const Icon(Icons.checkroom, color: GlamoraColors.deepNavy),
                  title: Text(event['note'] ?? 'No Title'),
                  // İstersen buraya silme butonu da ekleyebilirsin
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GlamoraColors.deepNavy,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}