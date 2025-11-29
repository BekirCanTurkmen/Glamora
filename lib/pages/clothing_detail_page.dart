import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/glamora_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ai_service.dart';

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

  // ------------ FIRESTORE UPDATE ------------
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

  // ------------ OPTION LISTS ------------
  final List<String> categoryOptions = [
    "Tops",
    "Bottoms",
    "Dresses",
    "Shoes",
    "Outerwear",
    "Accessories",
    "Others",
  ];

  List<String> getDynamicSizeList() {
    switch (item["category"]) {
      case "Shoes":
        return ["35", "36", "37", "38", "39", "40", "41", "42", "43"];
      case "Bottoms":
        return ["28", "29", "30", "31", "32", "33", "34", "36"];
      case "Tops":
      case "Outerwear":
        return ["XS", "S", "M", "L", "XL"];
      case "Dresses":
        return ["XS", "S", "M", "L"];
      default:
        return ["XS", "S", "M", "L", "XL", "36", "38", "40"];
    }
  }

  final List<String> stateOptions = [
    "New",
    "Like New",
    "Used",
    "Worn",
  ];

  final Map<String, IconData> stateIcons = {
    "New": Icons.fiber_new,
    "Like New": Icons.check_circle,
    "Used": Icons.history,
    "Worn": Icons.warning_amber,
  };

  // ------------ GENERIC SELECTOR DIALOG ------------
  Future<String?> selectFromList(String title, List<String> options) async {
    return await showDialog<String>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlamoraColors.deepNavy)),
                const SizedBox(height: 14),

                ...options.map((opt) => InkWell(
                  onTap: () => Navigator.pop(context, opt),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(opt,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: GlamoraColors.deepNavy)),
                  ),
                )),

                const Divider(),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"))
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------ CATEGORY SELECTOR ------------
  Future<void> editCategory() async {
    final result = await selectFromList("Select Category", categoryOptions);
    if (result != null) {
      updateField("category", result);
      final newSizes = getDynamicSizeList();
      if (!newSizes.contains(item["size"])) {
        updateField("size", "-");
      }
    }
  }

  // ------------ SIZE SELECTOR ------------
  Future<void> editSize() async {
    final sizeList = getDynamicSizeList();
    final result = await selectFromList("Select Size", sizeList);
    if (result != null) updateField("size", result);
  }

  // ------------ BRAND SEARCH DROPDOWN ------------
  Future<void> editBrand() async {
    final controller = TextEditingController();

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseFirestore.instance
        .collection("glamora_users")
        .doc(uid)
        .collection("wardrobe")
        .get();

    List<String> allBrands = snap.docs
        .map((e) => (e.data()["brand"] ?? "").toString().trim())
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();

    String? result = await showDialog<String>(
        context: context,
        builder: (_) {
          return StatefulBuilder(builder: (context, setStateX) {
            List<String> filtered = allBrands
                .where((b) =>
                b.toLowerCase().contains(controller.text.toLowerCase()))
                .toList();

            return Dialog(
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text("Select Brand",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: GlamoraColors.deepNavy)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    onChanged: (_) => setStateX(() {}),
                    decoration: const InputDecoration(
                      hintText: "Search...",
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      children: [
                        ...filtered.map((b) => ListTile(
                          title: Text(b),
                          onTap: () => Navigator.pop(context, b),
                        )),
                      ],
                    ),
                  ),
                  const Divider(),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"))
                ]),
              ),
            );
          });
        });

    if (result != null) updateField("brand", result);
  }

  // ------------ SEASON (AI SUGGESTION) ------------
  Future<void> editSeason() async {
    // AI’dan öneri alıyoruz
    final aiPrompt =
        "Aşağıdaki kıyafet için uygun sezonu öner: kategori: ${item["category"]}, renk: ${item["colorLabel"]}. Cevap sadece bir kelime olsun (Spring, Summer, Fall, Winter).";

    String? aiSuggestion = await AiService.askGemini(aiPrompt) ?? "Summer";

    aiSuggestion = aiSuggestion.trim().split(" ").first;

    final seasonList = ["Spring", "Summer", "Fall", "Winter"];

    final result = await selectFromList(
      "Select Season (AI suggests: $aiSuggestion)",
      seasonList,
    );

    if (result != null) updateField("season", result);
  }

  // ------------ STATE (ICON SELECTOR) ------------
  Future<void> editState() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text("Select Condition",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: GlamoraColors.deepNavy)),
              const SizedBox(height: 14),
              ...stateOptions.map((s) => ListTile(
                leading: Icon(stateIcons[s], color: GlamoraColors.deepNavy),
                title: Text(s,
                    style: const TextStyle(
                        color: GlamoraColors.deepNavy,
                        fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, s),
              )),
              const Divider(),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"))
            ]),
          ),
        );
      },
    );

    if (result != null) updateField("state", result);
  }

  // ------------ PRICE ------------
  Future<void> editPrice() async {
    final controller =
    TextEditingController(text: item["price"]?.toString() ?? "");

    final result = await showDialog<String>(
        context: context,
        builder: (_) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text("Edit Price",
                      style: TextStyle(
                          fontSize: 20,
                          color: GlamoraColors.deepNavy,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Enter price"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, controller.text.trim()),
                      child: const Text("Save"))
                ]),
              ));
        });

    if (result != null) updateField("price", result);
  }

  // ------------ DATE PICKER ------------
  Future<void> editDate() async {
    final initial = DateTime.tryParse(item["datePurchased"] ?? "") ??
        DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      updateField("datePurchased",
          selected.toIso8601String().split("T")[0]);
    }
  }

  // ------------ CUSTOM ROW ------------
  Widget customRow(String label, dynamic value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: GlamoraColors.deepNavy)),
            Text(value?.toString().isNotEmpty == true ? value.toString() : "-",
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // ------------ UI ------------
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
              aspectRatio: 1, child: Image.network(imageUrl, fit: BoxFit.cover)),
          const Divider(),

          Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  customRow("Category", item["category"], editCategory),
                  customRow("Brand", item["brand"], editBrand),
                  customRow("Size", item["size"], editSize),
                  customRow("Color", item["colorLabel"], () {}),
                  customRow("Price", item["price"], editPrice),
                  customRow("Season", item["season"], editSeason),
                  customRow("State", item["state"], editState),
                  customRow(
                      "Date Purchased", item["datePurchased"], editDate),
                ],
              ))
        ],
      ),
    );
  }
}
