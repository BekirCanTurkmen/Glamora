import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/glamora_theme.dart';
import 'package:dolabim/pages/outfit_result_page.dart';

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
  
  // Seçili gün varsayılan olarak bugün olsun
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('glamora_users')
          .doc(uid)
          .collection('planner')
          .get();

      final Map<DateTime, List<dynamic>> loadedEvents = {};

      for (var doc in snap.docs) {
        final data = doc.data();
        if (data['date'] == null) continue;

        final date = (data['date'] as Timestamp).toDate();
        final dayKey = DateTime(date.year, date.month, date.day);

        if (loadedEvents[dayKey] == null) {
          loadedEvents[dayKey] = [];
        }
        
        final eventData = data;
        eventData['id'] = doc.id; 
        
        loadedEvents[dayKey]!.add(eventData);
      }

      if (mounted) {
        setState(() {
          _events = loadedEvents;
        });
      }
    } catch (e) {
      print("Takvim hatası: $e");
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  Future<void> _deleteEvent(String docId) async {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
        .collection('glamora_users')
        .doc(uid)
        .collection('planner')
        .doc(docId)
        .delete();
      _fetchEvents();
  }

  // 🔥 ÇOKLU SEÇİM PENCERESİ
  void _showMultiSelectPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _MultiSelectWardrobe(
          selectedDay: _selectedDay!,
          onSaved: () {
            Navigator.pop(context);
            _fetchEvents(); // Listeyi yenile
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayEvents = _getEventsForDay(_selectedDay!);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Outfit Calendar", style: TextStyle(color: GlamoraColors.deepNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
      ),
      
      body: Column(
        children: [
          // 📅 TAKVİM KARTI (GÖRSEL DÜZELTME YAPILDI)
       // 📅 TAKVİM KARTI
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              
              // 🔥 GÖRSEL DÜZELTME: Satır yüksekliği ve renkler
              rowHeight: 42, 
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: GlamoraColors.deepNavy),
                leftChevronIcon: Icon(Icons.chevron_left, color: GlamoraColors.deepNavy),
                rightChevronIcon: Icon(Icons.chevron_right, color: GlamoraColors.deepNavy),
              ),
              
              // 🎨 GÜNLERİN RENKLERİNİ ZORLA AYARLIYORUZ
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: GlamoraColors.deepNavy, fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.black87), // Hafta içi rengi
                weekendTextStyle: TextStyle(color: Colors.black87), // Hafta sonu rengi
                outsideTextStyle: TextStyle(color: Colors.grey),    // Diğer ay günleri
                
                todayDecoration: BoxDecoration(color: GlamoraColors.creamBeige, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: GlamoraColors.deepNavy, shape: BoxShape.circle),
                todayTextStyle: TextStyle(color: GlamoraColors.deepNavy, fontWeight: FontWeight.bold),
                selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),

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
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  "Plans for this day", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GlamoraColors.deepNavy.withOpacity(0.8))
                ),
                const Spacer(),
                Text("${todayEvents.length} items", style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          ),
          
          // 📋 LİSTE
          Expanded(
            child: todayEvents.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note_rounded, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text("Nothing planned.", style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: todayEvents.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(todayEvents[index]);
                },
              ),
          ),
        ],
      ),
      
      // ➕ ÇOKLU EKLEME BUTONU
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GlamoraColors.deepNavy,
        onPressed: _showMultiSelectPicker, 
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Items", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    final bool isAiOutfit = event['outfitData'] != null; 
    final String title = event['note'] ?? 'Plan';
    final String imageUrl = event['imageUrl'] ?? ''; 

    return GestureDetector(
      onTap: () {
        if (isAiOutfit) {
          final uid = FirebaseAuth.instance.currentUser!.uid;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OutfitResultPage(
                userId: uid,
                outfitMap: event['outfitData'],
                planId: event['id'], // 🔥 ID'yi gönderiyoruz ki güncelleyebilsin
              ),
            ),
          ).then((_) => _fetchEvents()); // Dönünce yenile
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isAiOutfit ? Border.all(color: GlamoraColors.deepNavy.withOpacity(0.1), width: 1.5) : null,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70, height: 70,
                color: Colors.grey.shade100,
                child: isAiOutfit
                    ? Container(
                        color: GlamoraColors.deepNavy.withOpacity(0.05),
                        child: const Icon(Icons.auto_awesome, color: GlamoraColors.deepNavy),
                      )
                    : imageUrl.isNotEmpty
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.checkroom),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAiOutfit ? GlamoraColors.deepNavy.withOpacity(0.1) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAiOutfit ? "✨ AI Outfit" : "📌 Manual Item",
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        color: isAiOutfit ? GlamoraColors.deepNavy : Colors.grey.shade700
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: GlamoraColors.deepNavy),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.red.withOpacity(0.6)),
              onPressed: () {
                 if (event['id'] != null) _deleteEvent(event['id']);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 🧩 ÇOKLU SEÇİM İÇİN ALT WIDGET
class _MultiSelectWardrobe extends StatefulWidget {
  final DateTime selectedDay;
  final VoidCallback onSaved;

  const _MultiSelectWardrobe({required this.selectedDay, required this.onSaved});

  @override
  State<_MultiSelectWardrobe> createState() => _MultiSelectWardrobeState();
}

class _MultiSelectWardrobeState extends State<_MultiSelectWardrobe> {
  final Set<String> _selectedIds = {}; // Seçilenlerin ID'leri
  final Map<String, dynamic> _selectedData = {}; // Kaydetmek için data

  Future<void> _saveSelection() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final batch = FirebaseFirestore.instance.batch();

    for (var id in _selectedIds) {
      final item = _selectedData[id];
      final docRef = FirebaseFirestore.instance
          .collection('glamora_users')
          .doc(uid)
          .collection('planner')
          .doc(); // Yeni ID
      
      batch.set(docRef, {
        'date': Timestamp.fromDate(widget.selectedDay),
        'imageUrl': item['imageUrl'],
        'note': "${item['brand']} ${item['category']}",
        'type': 'manual',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Column(
        children: [
          Container(
            width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Items", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: GlamoraColors.deepNavy)),
                if (_selectedIds.isNotEmpty)
                  TextButton.icon(
                    onPressed: _saveSelection,
                    icon: const Icon(Icons.check),
                    label: Text("Add (${_selectedIds.length})"),
                    style: TextButton.styleFrom(backgroundColor: GlamoraColors.deepNavy, foregroundColor: Colors.white),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('glamora_users')
                  .doc(uid)
                  .collection('wardrobe')
                  .orderBy('uploadedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;
                    final isSelected = _selectedIds.contains(id);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(id);
                            _selectedData.remove(id);
                          } else {
                            _selectedIds.add(id);
                            _selectedData[id] = data;
                          }
                        });
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // RESİM
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(data['imageUrl'] ?? '', fit: BoxFit.cover),
                          ),
                          // SEÇİLİ KATMANI (YEŞİL PERDE)
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                color: GlamoraColors.deepNavy.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 30)),
                            ),
                        ],
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
  }
}