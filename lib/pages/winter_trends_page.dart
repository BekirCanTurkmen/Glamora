import 'package:flutter/material.dart';
import '../theme/glamora_theme.dart';

class WinterTrendsPage extends StatelessWidget {
  const WinterTrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
        title: const Text(
          "Winter Trends",
          style: TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // HERO SECTION
          Container(
            height: 380,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=1200",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "WINTER 2024–2025",
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Quiet Luxury\nReimagined",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Elevated layers, rich textures, timeless silhouettes",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // INTRO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Season Overview",
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: GlamoraColors.deepNavy.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This winter focuses on refined minimalism. Think oversized tailoring, luxurious fabrics, and neutral palettes that feel powerful yet effortless.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // TREND 1
          _buildEditorialCard(
            imageUrl:
            "https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800",
            category: "OUTERWEAR",
            title: "Oversized Coats",
            description:
            "Oversized coats dominate winter wardrobes with strong shoulders and relaxed silhouettes. Both practical and fashion-forward, they elevate any look instantly.",
            tips: [
              "Balance volume with slim trousers",
              "Add a belt for waist definition",
              "Choose wool or cashmere blends",
            ],
            brands: ["Max Mara", "The Row", "Totême", "COS"],
          ),

          // TREND 2
          _buildEditorialCard(
            imageUrl:
            "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800",
            category: "COLOR PALETTE",
            title: "Deep Navy & Cream",
            description:
            "A timeless winter color story. Deep navy paired with warm cream tones delivers sophistication without effort.",
            tips: [
              "Create monochrome looks",
              "Layer different fabric textures",
              "Finish with gold accents",
            ],
            brands: ["Chanel", "Khaite", "Akris"],
          ),

          // TREND 3
          _buildEditorialCard(
            imageUrl:
            "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800",
            category: "TEXTURE",
            title: "Wool & Knitwear",
            description:
            "Chunky knits, fine merino, and soft wool blends are essential this season. Cozy meets chic in perfectly layered combinations.",
            tips: [
              "Mix chunky and fine knits",
              "Layer knits over skirts",
              "Opt for turtlenecks",
            ],
            brands: ["Loro Piana", "Brunello Cucinelli", "Uniqlo U"],
          ),

          // TREND 4
          _buildEditorialCard(
            imageUrl:
            "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800",
            category: "MINIMALISM",
            title: "Timeless Essentials",
            description:
            "Clean cuts and quality fabrics define this trend. Minimal pieces become statement looks when executed perfectly.",
            tips: [
              "Stick to neutral tones",
              "Avoid unnecessary details",
              "Focus on fit and fabric",
            ],
            brands: ["The Row", "COS", "Arket"],
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildEditorialCard({
    required String imageUrl,
    required String category,
    required String title,
    required String description,
    required List<String> tips,
    required List<String> brands,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: GlamoraColors.deepNavy,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: GlamoraColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "STYLING TIPS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: GlamoraColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 10),
                ...tips.map(
                      (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Text("• ",
                            style: TextStyle(
                                color: GlamoraColors.deepNavy)),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "AS SEEN AT",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: GlamoraColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: brands
                      .map(
                        (brand) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                          GlamoraColors.deepNavy.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        brand,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GlamoraColors.deepNavy,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
