import 'package:flutter/material.dart';
import '../theme/glamora_theme.dart';

class SpringTrendsPage extends StatelessWidget {
  const SpringTrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
        title: const Text(
          "Spring Trends",
          style: TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero Section
          Container(
            height: 380,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
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
                    "SPRING 2025",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "The New\nRomanticism",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Soft power dressing meets bohemian elegance",
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

          // Intro Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "From the Runways",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GlamoraColors.deepNavy.withOpacity(0.6),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This season brings a refreshing shift: designers are embracing personal style over fleeting trends. The result? Collections that feel intimate, sophisticated, and endlessly wearable.",
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

          // Trend 1: Powder Pink
          _buildEditorialCard(
            context,
            imageUrl: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=800",
            category: "COLOR OF THE SEASON",
            title: "Powder Pink Perfection",
            description: "Soft, airy shades of powder pink dominated Fashion Week, from Alaïa's sculptural separates to Chanel's romantic silhouettes. This isn't your typical spring pastel—it's sophisticated, modern, and surprisingly versatile.",
            tips: [
              "Create monochromatic looks for maximum impact",
              "Layer different pink tones for depth",
              "Pair with crisp white for a fresh contrast",
            ],
            brands: ["Alaïa", "Miu Miu", "Chanel", "Khaite", "Valentino"],
          ),

          // Trend 2: Sheer Elegance
          _buildEditorialCard(
            context,
            imageUrl: "https://images.unsplash.com/photo-1558769132-cb1aea1c98f7?w=800",
            category: "FABRIC FOCUS",
            title: "Ultra-Sheer Moments",
            description: "Transparency reigns supreme with delicate mesh, organza, and lace taking center stage. From Jacquemus to Coperni, designers are celebrating skin with artful, sophisticated layers.",
            tips: [
              "Layer sheer pieces over slip dresses",
              "Wear mesh skirts over tailored shorts",
              "Choose nude underlayers for elegance",
            ],
            brands: ["Jacquemus", "Coperni", "Chanel", "Giambattista Valli"],
          ),

          // Trend 3: Modern Bohemian
          _buildEditorialCard(
            context,
            imageUrl: "https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800",
            category: "BOHO REVIVAL",
            title: "Bohemian Renaissance",
            description: "Thanks to Chemena Kamali's vision at Chloé, bohemian style is back—but make it polished. Think romantic silhouettes, flowing fabrics, and a modern approach to '70s glamour.",
            tips: [
              "Invest in suede jackets and wide-leg jeans",
              "Layer delicate jewelry for a collected look",
              "Choose flowing maxi dresses in earth tones",
            ],
            brands: ["Chloé", "Isabel Marant", "Valentino", "Hermès"],
          ),

          // Trend 4: Prep School Redux
          _buildEditorialCard(
            context,
            imageUrl: "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800",
            category: "COLLEGIATE CHIC",
            title: "Athletic Academia",
            description: "Pleated skirts meet varsity jackets in this season's preppy revival. Miu Miu and Akris lead the charge with sporty-meets-scholarly pieces that balance polish with playfulness.",
            tips: [
              "Mix athletic pieces with tailored items",
              "Layer cardigans over collared shirts",
              "Try pleated skirts with chunky sneakers",
            ],
            brands: ["Miu Miu", "Prada", "Akris", "Tory Burch"],
          ),

          // Trend 5: Tactile Textures
          _buildEditorialCard(
            context,
            imageUrl: "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800",
            category: "TEXTILE INNOVATION",
            title: "Touchable Fashion",
            description: "Fringe, feathers, and dimensional fabrics create pieces that beg to be touched. Alaïa's spiraled fringe coats and Chanel's delicate feathers showcase fashion's tactile evolution.",
            tips: [
              "Let statement texture pieces be the focus",
              "Balance dramatic textures with simple silhouettes",
              "Try fringe accessories for subtle impact",
            ],
            brands: ["Alaïa", "Proenza Schouler", "Loewe", "Bottega Veneta"],
          ),

          // Trend 6: Nautical Luxe
          _buildEditorialCard(
            context,
            imageUrl: "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800",
            category: "COASTAL INFLUENCE",
            title: "Modern Sailor",
            description: "Breton stripes, fisherman knits, and coastal prep with a twist. The nautical trend gets a sophisticated update with luxe fabrics and relaxed silhouettes.",
            tips: [
              "Embrace classic marinière stripes",
              "Layer cable-knit sweaters casually",
              "Try wide-leg sailor pants",
            ],
            brands: ["Tory Burch", "Ralph Lauren", "Miu Miu", "COS"],
          ),

          const SizedBox(height: 24),

          // Outfit Formula Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: GlamoraColors.deepNavy,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "The Perfect Outfit Formulas",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlamoraColors.deepNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildOutfitFormula(
                  "Weekend Brunch",
                  "Powder pink linen shirt + cream wide-leg pants + gold hoop earrings + tan leather mules",
                  Icons.coffee_outlined,
                ),
                const Divider(height: 32),
                _buildOutfitFormula(
                  "Office Power",
                  "Soft gray blazer + white silk camisole + pleated midi skirt + minimal jewelry + block heels",
                  Icons.business_center_outlined,
                ),
                const Divider(height: 32),
                _buildOutfitFormula(
                  "Date Night",
                  "Sheer organza blouse + slip dress underneath + delicate necklace + strappy sandals + clutch",
                  Icons.favorite_outline,
                ),
                const Divider(height: 32),
                _buildOutfitFormula(
                  "Casual Chic",
                  "Oversized shirt + vintage jeans + raffia bag + white sneakers + layered necklaces",
                  Icons.shopping_bag_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Style Manifesto
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GlamoraColors.deepNavy.withOpacity(0.03),
                  GlamoraColors.deepNavy.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Your Spring Style Manifesto",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GlamoraColors.deepNavy,
                  ),
                ),
                SizedBox(height: 16),
                _ManifestoItem(
                  "Embrace softness as strength—powder pinks and flowing silhouettes exude confidence",
                ),
                _ManifestoItem(
                  "Mix high and low: pair runway-inspired pieces with accessible basics",
                ),
                _ManifestoItem(
                  "Invest in quality natural fabrics that breathe and age beautifully",
                ),
                _ManifestoItem(
                  "Create your signature style by combining trends that resonate with you",
                ),
                _ManifestoItem(
                  "Remember: the best trend is one that makes you feel like yourself",
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildEditorialCard(
      BuildContext context, {
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
          // Image with overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 280,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 60, color: Colors.grey),
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: GlamoraColors.deepNavy,
                      letterSpacing: 1,
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
                    height: 1.2,
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
                    color: GlamoraColors.deepNavy,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: GlamoraColors.deepNavy,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                const Text(
                  "AS SEEN AT",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GlamoraColors.deepNavy,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: brands
                      .map((brand) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: GlamoraColors.deepNavy.withOpacity(0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      brand,
                      style: const TextStyle(
                        fontSize: 12,
                        color: GlamoraColors.deepNavy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitFormula(String occasion, String formula, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GlamoraColors.deepNavy.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: GlamoraColors.deepNavy,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                occasion,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: GlamoraColors.deepNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formula,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManifestoItem extends StatelessWidget {
  final String text;

  const _ManifestoItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "→",
            style: TextStyle(
              fontSize: 16,
              color: GlamoraColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}