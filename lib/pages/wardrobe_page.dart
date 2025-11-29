import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dolabim/pages/clothing_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/glamora_theme.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;   // 🔥 KEEP ALIVE ÇALIŞTIR

  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Tops",
    "Bottoms",
    "Dresses",
    "Outerwear",
    "Footwear",
    "Accessories",
    "Brands",
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context); // 🔥 MUTLAKA GEREKLİ

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("No user logged in"));
    }

    final wardrobeRef = FirebaseFirestore.instance
        .collection("glamora_users")
        .doc(user.uid)
        .collection("wardrobe");

    Query<Map<String, dynamic>> query = wardrobeRef.orderBy(
      "uploadedAt",
      descending: true,
    );

// CATEGORY FILTER (Tops, Bottoms, Dresses...)
    if (categories.contains(selectedCategory) &&
        selectedCategory != "All" &&
        selectedCategory != "Brands") {
      query = query.where("category", isEqualTo: selectedCategory);
    }

// BRAND FILTER
    else if (!categories.contains(selectedCategory) &&
        selectedCategory != "All" &&
        selectedCategory != "Brands") {
      query = query.where("brand", isEqualTo: selectedCategory);
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: GlamoraColors.deepNavy,
        ),
        title: Text(
          selectedCategory == "All" ? "My Wardrobe" : selectedCategory,
          style: const TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: Column(
        children: [
          // CATEGORY FILTER BAR
          SizedBox(
            height: 55,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : GlamoraColors.deepNavy,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: GlamoraColors.deepNavy,
                    backgroundColor: Colors.grey.shade200,
                    onSelected: (v) async {
                      if (cat == "Brands") {
                        // Brand seçim ekranına git
                        final selectedBrand = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _buildBrandListScreen(wardrobeRef),
                          ),
                        );

                        // Kullanıcı bir brand seçip döndüyse filtreyi uygula
                        if (selectedBrand != null) {
                          setState(() {
                            selectedCategory = selectedBrand;
                          });
                        }

                        return; // ❗ Brands açıldığı için Wardrobe filtren çizilmesin
                      }

                      // Normal kategoriler (Tops, Bottoms, Dresses...)
                      setState(() {
                        selectedCategory = cat;
                      });
                    },

                  ),
                );
              }).toList(),
            ),
          ),

          // WARDROBE LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: GlamoraColors.deepNavy,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No items found",
                      style: TextStyle(
                        color: GlamoraColors.deepNavy,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final items = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, i) {
                    final item = items[i].data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClothingDetailPage(
                              data: item,
                              docId: items[i].id,
                            )

                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: GlamoraColors.softWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: GlamoraColors.deepNavy.withOpacity(0.12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.network(
                                item["imageUrl"],
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                item["brand"] ?? "Unknown Brand",
                                style: const TextStyle(
                                  color: GlamoraColors.deepNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                item["category"] ?? "-",
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  // BRAND FILTER SCREEN
  Widget _buildBrandListScreen(CollectionReference ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: ref.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final rawItems = snapshot.data!.docs;
        final brandList = <String>{};

        for (var doc in rawItems) {
          final data = doc.data() as Map<String, dynamic>;
          if (data["brand"] != null && data["brand"].toString().trim() != "") {
            brandList.add(data["brand"]);
          }
        }

        final brands = brandList.toList();

        return Scaffold(
          backgroundColor: GlamoraColors.softWhite, // 🔥 ESKİ DOĞRU ARKAPLAN
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(
              color: GlamoraColors.deepNavy,
            ),
            title: const Text(
              "Brands",
              style: TextStyle(
                color: GlamoraColors.deepNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          body: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: brands.length,
            itemBuilder: (context, i) {
              return Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  title: Text(
                    brands[i],
                    style: const TextStyle(
                      color: GlamoraColors.deepNavy, // 🔥 KESİN GÖRÜNÜR
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedCategory = brands[i];
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

}
