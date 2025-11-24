import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/glamora_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClothingDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? docId;

  const ClothingDetailPage({
    super.key,
    required this.data,
    this.docId,
  });

  @override
  State<ClothingDetailPage> createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  late Map<String, dynamic> item;

  @override
  void initState() {
    super.initState();
    item = Map<String, dynamic>.from(widget.data);
  }

  /// ---------- FIRESTORE UPDATE ----------
  Future<void> updateField(String key, dynamic value) async {
    setState(() => item[key] = value);

    if (widget.docId == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("glamora_users")
        .doc(uid)
        .collection("wardrobe")
        .doc(widget.docId)
        .update({key: value});
  }


  /// ---------- MODERN POPUP ----------
  Future<void> editText(String label, String key) async {
    final controller = TextEditingController(text: item[key] ?? "");

    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,   // POPUP ARKA PLAN BEYAZ
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit $label",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GlamoraColors.deepNavy,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: GlamoraColors.deepNavy,   // ← METİN LACİVERT
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  cursorColor: GlamoraColors.deepNavy,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,         // ← ARKA PLAN BEYAZ
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: GlamoraColors.deepNavy,
                        width: 1.3,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(
                        color: GlamoraColors.deepNavy,
                        width: 1.8,
                      ),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlamoraColors.deepNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                      onPressed: () =>
                          Navigator.pop(context, controller.text.trim()),
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      },
    );

    if (result != null) updateField(key, result);
  }

  /// ---------- CLICKABLE FIELD ----------
  Widget editableRow(String label, String key) {
    return InkWell(
      onTap: () => editText(label, key),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: GlamoraColors.deepNavy,
              ),
            ),
            Text(
              item[key]?.toString().isNotEmpty == true
                  ? item[key].toString()
                  : "-",
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- MAIN UI ----------
  @override
  Widget build(BuildContext context) {
    final imageUrl = item['imageUrl'] ?? "";

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: GlamoraColors.deepNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),

          const Divider(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                editableRow("Category", "category"),
                editableRow("Brand", "brand"),
                editableRow("Size", "size"),
                editableRow("Price", "price"),
                editableRow("Season", "season"),
                editableRow("State", "state"),
                editableRow("Date Purchased", "datePurchased"),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
