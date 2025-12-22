import 'package:flutter/material.dart';
import '../theme/glamora_theme.dart';

class WinterTrendsPage extends StatelessWidget {
  const WinterTrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "2024-2025 Winter Fashion Trends",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: GlamoraColors.deepNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Discover this season's most stylish and striking pieces",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),

          // Trend 1: Oversize Coats
          _buildTrendCard(
            context,
            title: "Oversized Coats",
            description:
            "The most popular trend this winter is oversized coats. Offering both comfort and style, these pieces are set to be the star of every outfit.",
            imageUrl: "https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800",
            tips: [
              "Balance with slim-fit pants",
              "Create silhouette with a belt",
              "Pair with heeled boots",
            ],
          ),

          const SizedBox(height: 20),

          // Trend 2: Deep Navy & Cream
          _buildTrendCard(
            context,
            title: "Deep Navy & Cream Tones",
            description:
            "A classic and timeless color palette. The combination of deep navy with cream tones creates a sophisticated look.",
            imageUrl: "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800",
            tips: [
              "Create monochromatic outfits",
              "Mix different textures together",
              "Complete with gold accessories",
            ],
          ),

          const SizedBox(height: 20),

          // Trend 3: Wool and Knitwear
          _buildTrendCard(
            context,
            title: "Wool and Knitwear Textures",
            description:
            "Cozy and comfortable wool sweaters, cardigans, and knit dresses are this season's essentials. The chicest form of layering.",
            imageUrl: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800",
            tips: [
              "Mix different knit textures",
              "Wear oversized sweaters over skirts",
              "Prefer turtleneck styles",
            ],
          ),

          const SizedBox(height: 20),

          // Trend 4: Minimal Style
          _buildTrendCard(
            context,
            title: "Minimal and Timeless Outfits",
            description:
            "Less is more! Clean cuts, quality fabrics, and sleek lines. The minimalist approach is at the forefront of fashion this winter.",
            imageUrl: "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800",
            tips: [
              "Invest in quality basic pieces",
              "Try monochrome combinations",
              "Avoid detailed accessories",
            ],
          ),

          const SizedBox(height: 20),

          // Trend 5: Leather Boots and Accessories
          _buildTrendCard(
            context,
            title: "Leather Boots and Scarves",
            description:
            "Classic leather boots and soft cashmere scarves are winter wardrobe must-haves. Both practical and stylish choices.",
            imageUrl: "https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=800",
            tips: [
              "Opt for over-the-knee boots",
              "Wrap large scarves over coats",
              "Mix leather and suede details",
            ],
          ),

          const SizedBox(height: 20),

          // Style Tips Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GlamoraColors.deepNavy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "💡 Style Tips",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GlamoraColors.deepNavy,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "• Layer your outfits to stay warm and look chic\n"
                      "• Focus on quality when choosing accessories\n"
                      "• Limit your color palette to 3-4 main colors\n"
                      "• Invest in timeless pieces\n"
                      "• Don't be afraid to create your own style",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
      BuildContext context, {
        required String title,
        required String description,
        required String imageUrl,
        required List<String> tips,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görsel
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 220,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 60, color: Colors.grey),
                );
              },
            ),
          ),

          // İçerik
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GlamoraColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Nasıl Kombin Yapılır:",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: GlamoraColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 6),
                ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          fontSize: 14,
                          color: GlamoraColors.deepNavy,
                        ),
                      ),
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
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}