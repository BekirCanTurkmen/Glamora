import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'photo_uploader.dart';
import '../theme/glamora_theme.dart';
import 'clothing_detail_page.dart'; // Eğer ayrı dosyadaysa bu satır senin path’inle eşleşmeli

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

  // ✅ Artık doğru Firestore path: glamora_users/{uid}/wardrobe
  Stream<QuerySnapshot<Map<String, dynamic>>> _getUserOutfits() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final ref = FirebaseFirestore.instance
        .collection('glamora_users') // 🔹 Değiştirildi
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
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Wardrobe",
          style: TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
      ),

      body: Column(
        children: [
          // 🔹 Category filter bar
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
                    backgroundColor: GlamoraColors.deepNavy,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? GlamoraColors.deepNavy
                          : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
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

          // 🔹 Outfit Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getUserOutfits(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(color: GlamoraColors.deepNavy),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No outfits in this category yet.",
                      style: TextStyle(
                        color: GlamoraColors.deepNavy,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final outfits = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: outfits.length,
                  itemBuilder: (context, index) {
                    final data = outfits[index].data();
                    final imageUrl = data['imageUrl'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClothingDetailPage(data: data),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
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
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.image_not_supported,
                                  color: Colors.grey, size: 48),
                            ),
                          ),
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

      // 🔹 Add outfit button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GlamoraColors.creamBeige,
        foregroundColor: GlamoraColors.deepNavy,
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
