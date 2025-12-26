import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/glamora_theme.dart';
import '../services/analytics_service.dart';

class StyleAnalyticsPage extends StatefulWidget {
  const StyleAnalyticsPage({super.key});

  @override
  State<StyleAnalyticsPage> createState() => _StyleAnalyticsPageState();
}

class _StyleAnalyticsPageState extends State<StyleAnalyticsPage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await AnalyticsService.getWardrobeStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          // Premium AppBar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: GlamoraColors.deepNavy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [GlamoraColors.deepNavy, Color(0xFF667eea)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.insights_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Style Analytics',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Your wardrobe insights',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: GlamoraColors.deepNavy),
              ),
            )
          else if (_stats == null || _stats!['totalItems'] == 0)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final totalItems = _stats!['totalItems'] as int;
    final styleScore = _stats!['styleScore'] as int;
    final colorDistribution = _stats!['colorDistribution'] as Map<String, int>;
    final categoryDistribution = _stats!['categoryDistribution'] as Map<String, int>;
    final mostUsedColors = _stats!['mostUsedColors'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Style Score Card
          _buildStyleScoreCard(styleScore, totalItems),
          const SizedBox(height: 20),

          // Quick Stats Row
          Row(
            children: [
              Expanded(child: _buildQuickStatCard(
                icon: Icons.palette_rounded,
                value: '${colorDistribution.length}',
                label: 'Colors',
                color: const Color(0xFFE91E63),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickStatCard(
                icon: Icons.category_rounded,
                value: '${categoryDistribution.length}',
                label: 'Categories',
                color: const Color(0xFF673AB7),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickStatCard(
                icon: Icons.checkroom_rounded,
                value: '$totalItems',
                label: 'Items',
                color: const Color(0xFF2196F3),
              )),
            ],
          ),
          const SizedBox(height: 24),

          // Color Palette
          _buildSectionTitle('Your Color Palette', Icons.color_lens_rounded),
          const SizedBox(height: 12),
          _buildColorPalette(mostUsedColors.cast<String>()),
          const SizedBox(height: 24),

          // Color Distribution
          _buildSectionTitle('Color Distribution', Icons.pie_chart_rounded),
          const SizedBox(height: 12),
          _buildColorDistributionCard(colorDistribution),
          const SizedBox(height: 24),

          // Category Breakdown
          _buildSectionTitle('Category Breakdown', Icons.donut_small_rounded),
          const SizedBox(height: 12),
          _buildCategoryBreakdownCard(categoryDistribution),
          const SizedBox(height: 24),

          // Style Tips
          _buildSectionTitle('Style Tips', Icons.tips_and_updates_rounded),
          const SizedBox(height: 12),
          _buildStyleTipsCard(),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStyleScoreCard(int score, int totalItems) {
    String scoreLabel;
    Color scoreColor;
    
    if (score >= 80) {
      scoreLabel = 'Fashion Expert';
      scoreColor = const Color(0xFF4CAF50);
    } else if (score >= 60) {
      scoreLabel = 'Style Savvy';
      scoreColor = const Color(0xFF8BC34A);
    } else if (score >= 40) {
      scoreLabel = 'Growing Collection';
      scoreColor = const Color(0xFFFFC107);
    } else {
      scoreLabel = 'Just Starting';
      scoreColor = const Color(0xFFFF9800);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score Circle
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(scoreColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      'pts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          
          // Score Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    scoreLabel,
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Style Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on variety & collection size',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: GlamoraColors.deepNavy, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: GlamoraColors.deepNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildColorPalette(List<String> colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: colors.map((colorName) {
          final color = AnalyticsService.getColorFromLabel(colorName);
          return Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                colorName,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorDistributionCard(Map<String, int> distribution) {
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sortedEntries.fold<int>(0, (sum, e) => sum + e.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: sortedEntries.take(6).map((entry) {
          final percent = (entry.value / total * 100).round();
          final color = AnalyticsService.getColorFromLabel(entry.key);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '${entry.value} ($percent%)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / total,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(Map<String, int> distribution) {
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sortedEntries.fold<int>(0, (sum, e) => sum + e.value);

    final categoryIcons = {
      'Tops': Icons.layers,
      'Bottoms': Icons.straighten,
      'Dresses': Icons.dry_cleaning,
      'Outerwear': Icons.ac_unit,
      'Shoes': Icons.ice_skating,
      'Accessories': Icons.watch,
      'Bags': Icons.shopping_bag,
      'Other': Icons.more_horiz,
    };

    final categoryColors = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
      const Color(0xFFf093fb),
      const Color(0xFF4facfe),
      const Color(0xFF00f2fe),
      const Color(0xFF43e97b),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: sortedEntries.asMap().entries.map((mapEntry) {
          final index = mapEntry.key;
          final entry = mapEntry.value;
          final percent = (entry.value / total * 100).round();
          final color = categoryColors[index % categoryColors.length];
          final icon = categoryIcons[entry.key] ?? Icons.checkroom;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '${entry.value} items ($percent%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / total,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStyleTipsCard() {
    final tips = [
      '🎨 Try adding more neutral colors to create versatile outfits',
      '👗 Mix patterns with solid colors for balanced looks',
      '✨ Accessorize to transform basic outfits',
      '🔄 Rotate seasonal items to keep your wardrobe fresh',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlamoraColors.deepNavy.withOpacity(0.05),
            const Color(0xFF667eea).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GlamoraColors.deepNavy.withOpacity(0.1)),
      ),
      child: Column(
        children: tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: GlamoraColors.deepNavy.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checkroom_rounded,
                size: 64,
                color: GlamoraColors.deepNavy,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Items Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: GlamoraColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to your wardrobe to see your style analytics',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
