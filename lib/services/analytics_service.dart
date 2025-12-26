import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Gardırop istatistiklerini hesapla
  static Future<Map<String, dynamic>> getWardrobeStats() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final snapshot = await _firestore
        .collection('glamora_users')
        .doc(user.uid)
        .collection('wardrobe')
        .get();

    final items = snapshot.docs;
    
    if (items.isEmpty) {
      return {
        'totalItems': 0,
        'colorDistribution': <String, int>{},
        'categoryDistribution': <String, int>{},
        'brandDistribution': <String, int>{},
        'recentlyAdded': <Map<String, dynamic>>[],
        'mostUsedColors': <String>[],
        'styleScore': 0,
      };
    }

    // Renk dağılımı
    final colorDistribution = <String, int>{};
    // Kategori dağılımı  
    final categoryDistribution = <String, int>{};
    // Marka dağılımı
    final brandDistribution = <String, int>{};
    // Son eklenenler
    final recentItems = <Map<String, dynamic>>[];

    for (final doc in items) {
      final data = doc.data();
      
      // Renk sayımı
      final color = (data['colorLabel'] ?? 'Unknown').toString();
      colorDistribution[color] = (colorDistribution[color] ?? 0) + 1;
      
      // Kategori sayımı
      final category = (data['category'] ?? 'Other').toString();
      categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
      
      // Marka sayımı
      final brand = (data['brand'] ?? 'Unknown').toString();
      if (brand.isNotEmpty && brand != 'Unknown') {
        brandDistribution[brand] = (brandDistribution[brand] ?? 0) + 1;
      }
      
      // Son eklenenler için
      recentItems.add({
        'id': doc.id,
        'imageUrl': data['imageUrl'],
        'category': category,
        'color': color,
        'uploadedAt': data['uploadedAt'],
      });
    }

    // En son eklenen 5 parça
    recentItems.sort((a, b) {
      final aTime = a['uploadedAt'] as Timestamp?;
      final bTime = b['uploadedAt'] as Timestamp?;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    // En çok kullanılan 5 renk
    final sortedColors = colorDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostUsedColors = sortedColors.take(5).map((e) => e.key).toList();

    // Style Score hesaplama (çeşitlilik bazlı)
    final colorVariety = colorDistribution.length;
    final categoryVariety = categoryDistribution.length;
    final totalItems = items.length;
    
    // Skor: renk çeşitliliği + kategori çeşitliliği + toplam parça
    int styleScore = 0;
    if (totalItems >= 10) styleScore += 20;
    if (totalItems >= 20) styleScore += 10;
    if (colorVariety >= 5) styleScore += 25;
    if (colorVariety >= 8) styleScore += 15;
    if (categoryVariety >= 4) styleScore += 20;
    if (categoryVariety >= 6) styleScore += 10;
    styleScore = styleScore.clamp(0, 100);

    return {
      'totalItems': totalItems,
      'colorDistribution': colorDistribution,
      'categoryDistribution': categoryDistribution,
      'brandDistribution': brandDistribution,
      'recentlyAdded': recentItems.take(5).toList(),
      'mostUsedColors': mostUsedColors,
      'styleScore': styleScore,
      'colorVariety': colorVariety,
      'categoryVariety': categoryVariety,
    };
  }

  /// Renk için hex kodu döndür
  static Color getColorFromLabel(String label) {
    final colorMap = {
      'Red': const Color(0xFFE53935),
      'Pink': const Color(0xFFEC407A),
      'Purple': const Color(0xFF7B1FA2),
      'Deep Purple': const Color(0xFF512DA8),
      'Indigo': const Color(0xFF3949AB),
      'Blue': const Color(0xFF1E88E5),
      'Light Blue': const Color(0xFF039BE5),
      'Cyan': const Color(0xFF00ACC1),
      'Teal': const Color(0xFF00897B),
      'Green': const Color(0xFF43A047),
      'Light Green': const Color(0xFF7CB342),
      'Lime': const Color(0xFFC0CA33),
      'Yellow': const Color(0xFFFDD835),
      'Amber': const Color(0xFFFFB300),
      'Orange': const Color(0xFFFB8C00),
      'Deep Orange': const Color(0xFFF4511E),
      'Brown': const Color(0xFF6D4C41),
      'Grey': const Color(0xFF757575),
      'Blue Grey': const Color(0xFF546E7A),
      'Black': const Color(0xFF212121),
      'White': const Color(0xFFFAFAFA),
      'Beige': const Color(0xFFD7CCC8),
      'Navy': const Color(0xFF1A237E),
      'Cream': const Color(0xFFFFF8E1),
    };
    
    return colorMap[label] ?? const Color(0xFF9E9E9E);
  }
}
