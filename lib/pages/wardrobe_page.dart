import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dolabim/pages/clothing_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/glamora_theme.dart';
import 'package:dolabim/pages/photo_uploader.dart';
import 'dart:math'; // Rastgele sayı üretmek için gerekli

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
      const SnackBar(content: Text("Rastgele kıyafetler üretiliyor..."), duration: Duration(milliseconds: 1500)),
    );

    // 1. Rastgelelik için Veri Havuzları
    final List<String> brands = ["Zara", "H&M", "Nike", "Adidas", "Gucci", "Mango", "Bershka", "Pull&Bear", "Prada", "Louis Vuitton", "Stradivarius", "Koton"];
    final List<String> colors = ["Red", "Blue", "Black", "White", "Green", "Yellow", "Pink", "Beige", "Grey", "Navy", "Purple", "Orange"];
    
    // 2. Kategoriye Özel Geniş Resim Havuzu
    final Map<String, List<String>> categoryImages = {
      "Tops": [
        "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&q=80", // Beyaz T-shirt
        "https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=400&q=80", // Siyah Crop
        "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400&q=80", // Gömlek
        "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=400&q=80", // Siyah Basic
        "https://images.unsplash.com/photo-1620799140408-ed5341cd2431?w=400&q=80", // Beyaz Bluz
        "https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=400&q=80", // Desenli Gömlek
      ],
      "Bottoms": [
        "https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a?w=400&q=80", // Kot
        "https://images.unsplash.com/photo-1584370848010-d7cc31086f5b?w=400&q=80", // Gri Pantolon
        "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400&q=80", // Yırtık Kot
        "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400&q=80", // Bej Pantolon
        "https://images.unsplash.com/photo-1475178626620-a4d074967452?w=400&q=80", // Kot Şort
      ],
      "Outerwear": [
        "https://images.unsplash.com/photo-1551028919-ac7eddcb9885?w=400&q=80", // Deri Ceket
        "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&q=80", // Bej Ceket
        "https://images.unsplash.com/photo-1544923246-77307dd654cb?w=400&q=80", // Kahverengi Kaban
        "https://images.unsplash.com/photo-1520975916090-3105956dac38?w=400&q=80", // Denim Ceket
        "https://images.unsplash.com/photo-1559551409-dadc959f76b8?w=400&q=80", // Trençkot
      ],
      "Dresses": [
        "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400&q=80", // Kırmızı Elbise
        "https://images.unsplash.com/photo-1612336307429-8a898d10e223?w=400&q=80", // Siyah Elbise
        "https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=400&q=80", // Beyaz Elbise
        "https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400&q=80", // Yazlık Elbise
        "https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=400&q=80", // Çiçekli Elbise
      ],
      "Footwear": [
        "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&q=80", // Beyaz Sneaker
        "https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=400&q=80", // Bot
        "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&q=80", // Spor Ayakkabı
        "https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400&q=80", // Mavi Topuklu
        "https://images.unsplash.com/photo-1512374382149-233c42b6a83b?w=400&q=80", // Sarı Spor
      ],
      "Accessories": [
        "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400&q=80", // Kahverengi Çanta
        "https://images.unsplash.com/photo-1523293188086-b520e57f6014?w=400&q=80", // Saat
        "https://images.unsplash.com/photo-1576053139778-7e32f2ae3cfd?w=400&q=80", // Sarı Çanta
        "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=400&q=80", // Altın Kolye
        "https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400&q=80", // Güneş Gözlüğü
      ]
    };

    final batch = FirebaseFirestore.instance.batch();
    final random = Random();
    
    // 🔥 HER SEFERİNDE 5 YENİ EŞYA EKLE
    for (int i = 0; i < 5; i++) {
      // 1. Rastgele Kategori Seç (All ve Brands hariç)
      // categories listesindeki 1. indeksten (Tops) 6. indekse (Accessories) kadar
      String randomCategory = categories[random.nextInt(6) + 1]; 
      
      // 2. Rastgele Marka ve Renk
      String randomBrand = brands[random.nextInt(brands.length)];
      String randomColor = colors[random.nextInt(colors.length)];
      
      // 3. O Kategoriye Ait Rastgele Bir Resim
      List<String>? images = categoryImages[randomCategory];
      
      // Eğer listede resim yoksa veya hata olursa varsayılan bir tane ata
      String randomImage = "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400&q=80"; 
      if (images != null && images.isNotEmpty) {
        randomImage = images[random.nextInt(images.length)];
      }

      final docRef = FirebaseFirestore.instance
          .collection('glamora_users') // Koleksiyon adı Home ile aynı olmalı
          .doc(uid)
          .collection('wardrobe')
          .doc(); 
      
      batch.set(docRef, {
        "category": randomCategory,
        "brand": randomBrand,
        "colorLabel": randomColor,
        "imageUrl": randomImage,
        "uploadedAt": Timestamp.now(),
      });
    }

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ +5 Yeni Rastgele Parça Eklendi!")),
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
            tooltip: "Rastgele Kıyafet Ekle",
            icon: const Icon(Icons.playlist_add),
            onPressed: _addDemoData, 
          ),
          IconButton(
            tooltip: "Yeni Ekle",
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
                                child: Hero( // 🔥 YENİ: Hero ile sarıldı
                                  tag: item["imageUrl"] ?? "hero_${items[i].id}",
                                  child: Image.network(
                                    item["imageUrl"] ?? "",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                      const Center(child: Icon(Icons.broken_image)),
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