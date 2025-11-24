import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/glamora_theme.dart';
import 'clothing_detail_page.dart';
import 'photo_uploader.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  String selected = "All"; // Category + Brand state

  final List<String> categories = [
    "All",
    "Tops",
    "Bottoms",
    "Dresses",
    "Shoes",
    "Outerwear",
    "Accessories",
    "Others",
    "Brands", // brand filter tab
  ];

  /// ---------------------------------------------------------------------------
  /// FETCH BRANDS SAFELY (NO CRASH)
  /// ---------------------------------------------------------------------------
  Future<List<String>> _fetchBrands() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final snap = await FirebaseFirestore.instance
          .collection("glamora_users")
          .doc(uid)
          .collection("wardrobe")
          .get();

      final brands = snap.docs
          .map((e) => (e.data()["brand"] ?? "").toString().trim())
          .where((b) => b.isNotEmpty)
          .toSet()
          .toList();

      return List<String>.from(brands);
    } catch (e) {
      print("BRAND FETCH ERROR → $e");
      return [];
    }
  }

  /// ---------------------------------------------------------------------------
  /// STREAM WARDROBE ITEMS WITH CATEGORY / BRAND FILTER
  /// ---------------------------------------------------------------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> _streamWardrobe() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final baseRef = FirebaseFirestore.instance
        .collection("glamora_users")
        .doc(uid)
        .collection("wardrobe")
        .orderBy("uploadedAt", descending: true);

    // BRAND FILTER
    if (selected.startsWith("brand:")) {
      final brandName = selected.replaceFirst("brand:", "");
      return baseRef.where("brand", isEqualTo: brandName).snapshots();
    }

    // CATEGORY FILTER
    if (selected != "All" && selected != "Brands") {
      return baseRef.where("category", isEqualTo: selected).snapshots();
    }

    // DEFAULT → All items
    return baseRef.snapshots();
  }

  /// ---------------------------------------------------------------------------
  /// UI
  /// ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
        centerTitle: true,
        title: const Text(
          "My Wardrobe",
          style: TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),

          /// -------------------------------------------------------------------
          /// CATEGORY + BRAND TAB BAR
          /// -------------------------------------------------------------------
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: categories.map((c) {
                final isSelected = selected == c;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    selectedColor: GlamoraColors.creamBeige,
                    backgroundColor: GlamoraColors.deepNavy,
                    labelStyle: TextStyle(
                      color:
                      isSelected ? GlamoraColors.deepNavy : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() => selected = c);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          /// -------------------------------------------------------------------
          /// BRAND DROPDOWN (ONLY WHEN selected == "Brands")
          /// -------------------------------------------------------------------
          if (selected == "Brands")
            FutureBuilder<List<String>>(
              future: _fetchBrands(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: GlamoraColors.deepNavy,
                    ),
                  );
                }

                if (snap.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Failed to load brands.",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                final brands = snap.data ?? [];

                // EMPTY BRAND LIST
                if (brands.isEmpty) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GlamoraColors.creamBeige.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "No brands found.",
                      style: TextStyle(
                        color: GlamoraColors.deepNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                // BRAND LIST
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: GlamoraColors.creamBeige.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select Brand",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: GlamoraColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 8),

                      ...brands.map(
                            (brand) => InkWell(
                          onTap: () {
                            setState(() {
                              selected = "brand:$brand";
                            });
                          },
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              brand,
                              style: const TextStyle(
                                color: GlamoraColors.deepNavy,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Divider(),

                      InkWell(
                        onTap: () {
                          setState(() => selected = "All");
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            "Show All Brands",
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),

          /// -------------------------------------------------------------------
          /// GRID — WARDROBE ITEMS
          /// -------------------------------------------------------------------
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _streamWardrobe(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: GlamoraColors.deepNavy,
                    ),
                  );
                }

                final docs = snap.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No items found.",
                      style: TextStyle(
                        color: GlamoraColors.deepNavy,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final item = docs[i].data();
                    final id = docs[i].id;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClothingDetailPage(data: item, docId: id),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          item["imageUrl"],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GlamoraColors.creamBeige,
        foregroundColor: GlamoraColors.deepNavy,
        icon: const Icon(Icons.add),
        label: const Text("Add Outfit"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PhotoUploader()),
          );
        },
      ),
    );
  }
}
