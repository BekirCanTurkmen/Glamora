import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'photo_uploader.dart';
import '../theme/glamora_theme.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  String selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Tops",
    "Bottoms",
    "Dresses",
    "Shoes",
    "Outerwear",
    "Accessories",
    "Others",
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserOutfits() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe')
        .orderBy('uploadedAt', descending: true);

    if (selectedCategory == "All") {
      return ref.snapshots();
    } else {
      return ref.where('category', isEqualTo: selectedCategory).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ açık arka plan

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Wardrobe",
          style: TextStyle(
            color: GlamoraColors.deepNavy, // ✅ yazı rengi deepNavy
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
      ),

      body: Column(
        children: [
          // kategori filtreleri
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,

                    // 🔹 Seçilmediğinde lacivert arka plan + beyaz yazı
                    backgroundColor: GlamoraColors.deepNavy,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? GlamoraColors.deepNavy  // seçiliyken lacivert yazı
                          : Colors.white,            // seçili değilken beyaz yazı
                      fontWeight: FontWeight.w500,
                    ),

                    // 🔸 Seçiliyken bej arka plan
                    selectedColor: GlamoraColors.creamBeige,
                    checkmarkColor: GlamoraColors.deepNavy,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? GlamoraColors.creamBeige
                            : GlamoraColors.deepNavy.withOpacity(0.4),
                        width: 1,
                      ),
                    ),

                    onSelected: (_) => setState(() => selectedCategory = category),
                  ),

                );
              },
            ),
          ),

          // outfit grid
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getUserOutfits(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: GlamoraColors.deepNavy),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No outfits in this category yet.",
                      style: TextStyle(
                        color: GlamoraColors.deepNavy, // ✅ yazı deepNavy
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final outfits = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: outfits.length,
                  itemBuilder: (context, index) {
                    final data = outfits[index].data();
                    final imageUrl = data['imageUrl'] ?? '';

                    return Container(
                      decoration: BoxDecoration(
                        color: GlamoraColors.softWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GlamoraColors.deepNavy.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: GlamoraColors.deepNavy),
                            );
                          },
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
        backgroundColor: GlamoraColors.creamBeige, // ✅ bej buton
        foregroundColor: GlamoraColors.deepNavy, // ✅ lacivert yazı/ikon
        icon: const Icon(Icons.add_a_photo),
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
