import 'package:flutter/material.dart';
import '../theme/glamora_theme.dart';
import '../services/trend_matcher_service.dart';

class TrendMatcherPage extends StatefulWidget {
  const TrendMatcherPage({super.key});

  @override
  State<TrendMatcherPage> createState() => _TrendMatcherPageState();
}

class _TrendMatcherPageState extends State<TrendMatcherPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _trendData;
  bool _isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadTrends();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadTrends() async {
    setState(() => _isLoading = true);
    final data = await TrendMatcherService.getTrendMatches();
    if (mounted) {
      setState(() {
        _trendData = data;
        _isLoading = false;
      });
    }
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF667eea);
    }
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'checkroom': Icons.checkroom,
      'style': Icons.style,
      'layers': Icons.layers,
      'eco': Icons.eco,
      'palette': Icons.palette,
      'auto_awesome': Icons.auto_awesome,
      'trending_up': Icons.trending_up,
      'star': Icons.star,
      'diamond': Icons.diamond,
      'bolt': Icons.bolt,
    };
    return iconMap[iconName] ?? Icons.checkroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          // Premium AppBar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF667eea),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _loadTrends,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
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
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2 + _pulseController.value * 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 15 + _pulseController.value * 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 32),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trend Matcher',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Match trends with your wardrobe',
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
            SliverFillRemaining(child: _buildLoadingState())
          else
            SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFf093fb).withOpacity(0.1 + _pulseController.value * 0.1),
                      const Color(0xFFf5576c).withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up,
                  size: 48,
                  color: Color(0xFFf5576c),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyzing fashion trends...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: GlamoraColors.deepNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Matching with your wardrobe',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation(Color(0xFFf5576c)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final trends = _trendData!['trends'] as List? ?? [];
    final overallMatch = _trendData!['overallMatch'] as int? ?? 0;
    final topTrend = _trendData!['topMatchingTrend'] as String? ?? '';
    final suggestions = _trendData!['suggestions'] as List? ?? [];
    final seasonalTip = _trendData!['seasonalTip'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Match Score
          _buildOverallMatchCard(overallMatch, topTrend),
          const SizedBox(height: 24),

          // Trends List
          _buildSectionTitle('Current Trends', Icons.auto_awesome_rounded),
          const SizedBox(height: 12),
          if (trends.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.trending_up_rounded, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Trend analizi yapılıyor...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gardırobunuza parça ekleyerek daha iyi sonuçlar alın',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          else
            ...trends.map((trend) => _buildTrendCard(trend as Map<String, dynamic>)),
          
          // Seasonal Tip
          if (seasonalTip.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('Seasonal Insight', Icons.wb_sunny_rounded),
            const SizedBox(height: 12),
            _buildSeasonalTipCard(seasonalTip),
          ],

          // Suggestions
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('Style Suggestions', Icons.lightbulb_rounded),
            const SizedBox(height: 12),
            _buildSuggestionsCard(suggestions.cast<String>()),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOverallMatchCard(int matchPercent, String topTrend) {
    Color matchColor;
    String matchLabel;
    
    if (matchPercent >= 70) {
      matchColor = const Color(0xFF4CAF50);
      matchLabel = 'Trendsetter! 🔥';
    } else if (matchPercent >= 50) {
      matchColor = const Color(0xFF8BC34A);
      matchLabel = 'On Point! 👌';
    } else if (matchPercent >= 30) {
      matchColor = const Color(0xFFFFC107);
      matchLabel = 'Getting There! 📈';
    } else {
      matchColor = const Color(0xFFFF9800);
      matchLabel = 'Room to Grow! 🌱';
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
                    value: matchPercent / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(matchColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$matchPercent%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: matchColor,
                      ),
                    ),
                    Text(
                      'match',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFf093fb).withOpacity(0.15),
                        const Color(0xFFf5576c).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    matchLabel,
                    style: const TextStyle(
                      color: Color(0xFFf5576c),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Trend Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                if (topTrend.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Best match: $topTrend',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
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

  Widget _buildTrendCard(Map<String, dynamic> trend) {
    final name = trend['name'] as String? ?? '';
    final description = trend['description'] as String? ?? '';
    final matchPercent = trend['matchPercentage'] as int? ?? 0;
    final matchingItems = (trend['matchingItems'] as List?)?.cast<String>() ?? [];
    final missingItems = (trend['missingItems'] as List?)?.cast<String>() ?? [];
    final iconName = trend['icon'] as String? ?? 'checkroom';
    final colorHex = trend['color'] as String? ?? '#667eea';
    
    final color = _parseColor(colorHex);
    final icon = _getIconData(iconName);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: GlamoraColors.deepNavy,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Match percentage bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: matchPercent / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$matchPercent%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            // Matching Items
            if (matchingItems.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[400]),
                  const SizedBox(width: 6),
                  Text(
                    'You have:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: matchingItems.map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Missing Items
            if (missingItems.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 16, color: Colors.orange[400]),
                  const SizedBox(width: 6),
                  Text(
                    'Consider adding:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: missingItems.map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalTipCard(String tip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFf093fb).withOpacity(0.08),
            const Color(0xFFf5576c).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFf5576c).withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFf5576c).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.wb_sunny, color: Color(0xFFf5576c), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard(List<String> suggestions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: suggestions.asMap().entries.map((entry) {
          final index = entry.key;
          final suggestion = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < suggestions.length - 1 ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
