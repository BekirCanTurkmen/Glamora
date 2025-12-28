import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dolabim/pages/clothing_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/glamora_theme.dart';
import 'package:dolabim/pages/photo_uploader.dart';
import 'dart:math';
import 'package:palette_generator/palette_generator.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;   // Sayfa değişince veriler kaybolmasın

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

  // 🎲 GELİŞMİŞ RASTGELE KIYAFET EKLEYİCİ
  Future<void> _addDemoData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Adding random clothes (center region color analysis)..."),
        duration: Duration(milliseconds: 1500),
      ),
    );

    final random = Random();

    final brands = [
      "Zara","H&M","Nike","Adidas","Gucci",
      "Mango","Bershka","Pull&Bear",
      "Prada","Louis Vuitton","Stradivarius","Koton"
    ];

    final Map<String, List<String>> categoryImages = {
      "Tops": [
        "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&q=80",
        "https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=400&q=80",
        "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400&q=80",
        "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=400&q=80",
        "https://images.unsplash.com/photo-1620799140408-ed5341cd2431?w=400&q=80",
        "https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=400&q=80",
      ],
      "Bottoms": [
        "https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a?w=400&q=80",
        "https://images.unsplash.com/photo-1584370848010-d7cc31086f5b?w=400&q=80",
        "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400&q=80",
        "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400&q=80",
        "https://images.unsplash.com/photo-1475178626620-a4d074967452?w=400&q=80",
      ],
      "Dresses": [
        "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80",
        "https://images.unsplash.com/photo-1612336307429-8a898d10e223?w=400&q=80",
        "https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=400&q=80",
        "https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400&q=80",
        "https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=400&q=80",
      ],
      "Outerwear": [
        "https://images.unsplash.com/photo-1551028919-ac7eddcb9885?w=400&q=80",
        "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&q=80",
        "https://images.unsplash.com/photo-1544923246-77307dd654cb?w=400&q=80",
        "https://images.unsplash.com/photo-1520975916090-3105956dac38?w=400&q=80",
        "https://images.unsplash.com/photo-1559551409-dadc959f76b8?w=400&q=80",
      ],
      "Footwear": [
        "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&q=80",
        "https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=400&q=80",
        "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&q=80",
        "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400&q=80",
        "https://images.unsplash.com/photo-1512374382149-233c42b6a83b?w=400&q=80",
      ],
      "Accessories": [
        "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400&q=80",
        "https://images.unsplash.com/photo-1523293188086-b520e57f6014?w=400&q=80",
        "https://images.unsplash.com/photo-1576053139778-7e32f2ae3cfd?w=400&q=80",
        "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=400&q=80",
        "https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400&q=80",
      ],
    };

    final batch = FirebaseFirestore.instance.batch();

    for (int i = 0; i < 5; i++) {
      final category = categories[random.nextInt(6) + 1];
      final imageUrl =
      categoryImages[category]![random.nextInt(categoryImages[category]!.length)];
      final brand = brands[random.nextInt(brands.length)];

      // 🎯 ORTA BÖLGE RENK ALGILAMA
      String colorLabel = "Unknown";
      try {
        final palette = await PaletteGenerator.fromImageProvider(
          NetworkImage(imageUrl),
          region: const Rect.fromLTWH(0.25, 0.20, 0.50, 0.60),
          size: const Size(200, 200),
          maximumColorCount: 16,
        );

        final Color? picked =
            palette.vibrantColor?.color ?? palette.dominantColor?.color;

        if (picked != null) {
          final hsv = HSVColor.fromColor(picked);
          final h = hsv.hue;
          final s = hsv.saturation;
          final v = hsv.value;

          if (v > 0.92 && s < 0.15) colorLabel = "White";
          else if (v < 0.18) colorLabel = "Black";
          else if (s < 0.12 && v < 0.85) colorLabel = "Grey";
          else if (h < 15 || h >= 330) colorLabel = "Red";
          else if (h < 35) colorLabel = "Orange";
          else if (h < 55) colorLabel = "Yellow";
          else if (h < 160) colorLabel = "Green";
          else if (h < 250) colorLabel = "Blue";
          else if (h < 290) colorLabel = "Purple";
          else colorLabel = "Pink";
        }
      } catch (_) {}

      final docRef = FirebaseFirestore.instance
          .collection("glamora_users")
          .doc(uid)
          .collection("wardrobe")
          .doc();

      batch.set(docRef, {
        "category": category,
        "brand": brand,
        "colorLabel": colorLabel,
        "imageUrl": imageUrl,
        "uploadedAt": Timestamp.now(),
      });
    }

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ +5 demo items added (colors detected correctly)"),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("No user logged in"));
    }

    final wardrobeRef = FirebaseFirestore.instance
        .collection("glamora_users") // Ana sayfa ile aynı
        .doc(user.uid)
        .collection("wardrobe");

    Query<Map<String, dynamic>> query = wardrobeRef.orderBy(
      "uploadedAt",
      descending: true,
    );

    // CATEGORY FILTER
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
        actions: [
          IconButton(
            tooltip: "Add Random Clothes",
            icon: const Icon(Icons.playlist_add),
            onPressed: _addDemoData, 
          ),
          IconButton(
            tooltip: "Add New",
            icon: const Icon(Icons.add),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const PhotoUploader()));
            },
          ),
        ],
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

                        if (selectedBrand != null) {
                          setState(() {
                            selectedCategory = selectedBrand;
                          });
                        }
                        return; 
                      }

                      // Normal kategoriler
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
                            Expanded( // Resmi Expanded yaptım ki taşmasın
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Hero(
                                  tag: item["imageUrl"] ?? "hero_${items[i].id}",
                                  child: CachedNetworkImage(
                                    imageUrl: item["imageUrl"] ?? "",
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: GlamoraColors.deepNavy,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Center(
                                      child: Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["brand"] ?? "Unknown Brand",
                                    style: const TextStyle(
                                      color: GlamoraColors.deepNavy,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item["category"] ?? "-",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
          backgroundColor: GlamoraColors.softWhite,
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
                      color: GlamoraColors.deepNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, brands[i]);
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