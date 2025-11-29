import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/glamora_theme.dart';

class OutfitResultPage extends StatefulWidget {
  final String? jsonResult;
  final Map<String, dynamic>? outfitMap; 
  final String userId;
  final String? planId; // 🔥 YENİ: Eğer düzenliyorsak bu ID dolu gelir

  const OutfitResultPage({
    super.key, 
    this.jsonResult, 
    this.outfitMap,
    required this.userId,
    this.planId,
  });

  @override
  State<OutfitResultPage> createState() => _OutfitResultPageState();
}

class _OutfitResultPageState extends State<OutfitResultPage> {
  late Map<String, dynamic> outfitData;
  bool isLoading = true;
  bool hasChanges = false; // 🔥 Değişiklik yapıldı mı kontrolü

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    try {
      if (widget.outfitMap != null) {
        // Derin kopya oluştur ki değişiklikler anında UI'ı bozmasın, kaydet deyince işlesin
        outfitData = Map<String, dynamic>.from(widget.outfitMap!);
        // items listesini de kopyalamamız lazım (Derin kopya için basit hack: encode/decode)
        outfitData = jsonDecode(jsonEncode(outfitData));
      } else if (widget.jsonResult != null) {
        outfitData = jsonDecode(widget.jsonResult!);
      } else {
        outfitData = {};
      }
      isLoading = false;
    } catch (e) {
      outfitData = {};
      isLoading = false;
    }
  }

  // 🔄 SWAP (Artık her zaman açık)
  void _swapItem(int index) {
    setState(() {
      var item = outfitData['items'][index];
      String currentId = item['selected_item_id'];
      String? altId = item['alternative_item_id'];

      if (altId != null && altId.isNotEmpty && altId != "null") {
        item['selected_item_id'] = altId;
        item['alternative_item_id'] = currentId; 
        hasChanges = true; // 🔥 Değişiklik algılandı

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parça değiştirildi!"), duration: Duration(milliseconds: 600)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alternatif öneri yok.")),
        );
      }
    });
  }

  // 📅 KAYDET veya GÜNCELLE
  Future<void> _saveOrUpdate() async {
    try {
      final calendarData = outfitData['calendar_entry'];
      
      final dataToSave = {
        'date': Timestamp.now(), // İstersen orijinal tarihi koruyabilirsin
        'note': "${calendarData['title']} - ${calendarData['description']}",
        'outfitData': outfitData,
        'type': 'ai_outfit',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.planId != null) {
        // 🔥 GÜNCELLEME MODU
        await FirebaseFirestore.instance
            .collection('glamora_users')
            .doc(widget.userId)
            .collection('planner')
            .doc(widget.planId)
            .update(dataToSave);
            
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Kombin Güncellendi!"), backgroundColor: Colors.blueAccent),
          );
        }
      } else {
        // 🔥 YENİ KAYIT MODU
        await FirebaseFirestore.instance
            .collection('glamora_users')
            .doc(widget.userId)
            .collection('planner')
            .add(dataToSave);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Takvime Kaydedildi!"), backgroundColor: Colors.green),
          );
        }
      }
      
      if (mounted) Navigator.pop(context); 

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || outfitData.isEmpty) {
      return const Scaffold(body: Center(child: Text("Veri işlenemedi.")));
    }

    final items = outfitData['items'] as List;
    final isEditing = widget.planId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(isEditing ? "Edit Outfit" : "Your AI Outfit", style: const TextStyle(color: GlamoraColors.deepNavy, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
      ),
      
      // Buton: Eğer düzenleme modundaysak ve değişiklik yoksa gösterme (veya pasif yap)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveOrUpdate,
        backgroundColor: (isEditing && !hasChanges) ? Colors.grey : GlamoraColors.deepNavy,
        icon: Icon(isEditing ? Icons.update : Icons.calendar_month, color: Colors.white),
        label: Text(
          isEditing ? "Update Plan" : "Save to Calendar", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (Aynı kalıyor, sadece biraz küçültebiliriz)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [GlamoraColors.deepNavy, GlamoraColors.deepNavy.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: GlamoraColors.deepNavy.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    outfitData['outfit_summary'] ?? "Günlük Kombin",
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Style Score: ${outfitData['total_style_score']}/10",
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Selected Pieces", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GlamoraColors.deepNavy)),
                if (isEditing) 
                  const Text("Tap sync to swap", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildClothingItem(items[index], index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingItem(Map<String, dynamic> itemJson, int index) {
    final String itemId = itemJson['selected_item_id'] ?? "";
    if (itemId.isEmpty) return const SizedBox();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('glamora_users') 
          .doc(widget.userId)
          .collection('wardrobe')
          .doc(itemId)
          .get(),
      builder: (context, snapshot) {
        String imageUrl = "";
        String title = itemJson['item_name'];
        String subtitle = itemJson['reason'];

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          imageUrl = data['imageUrl'] ?? "";
          title = "${data['brand'] ?? ''} ${data['category'] ?? ''}".trim(); 
          if (title.isEmpty) title = itemJson['item_name'];
        }

        return Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade100, child: const Icon(Icons.checkroom)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      itemJson['slot'].toString().toUpperCase(),
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: GlamoraColors.deepNavy),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 🔥 SWAP BUTONU HER ZAMAN AKTİF
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sync, color: GlamoraColors.deepNavy, size: 20),
                  onPressed: () => _swapItem(index),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}