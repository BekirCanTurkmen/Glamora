import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/glamora_theme.dart';
import '../services/style_coach_service.dart';

class StyleCoachPage extends StatefulWidget {
  const StyleCoachPage({super.key});

  @override
  State<StyleCoachPage> createState() => _StyleCoachPageState();
}

class _StyleCoachPageState extends State<StyleCoachPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _recommendations;
  bool _isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadRecommendations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    final recs = await StyleCoachService.getStyleRecommendations();
    if (mounted) {
      setState(() {
        _recommendations = recs;
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
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: GlamoraColors.deepNavy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _loadRecommendations,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
                            // Animated AI icon
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
                                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Style Coach',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Your personal fashion assistant',
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
                      const Color(0xFF667eea).withOpacity(0.1 + _pulseController.value * 0.1),
                      const Color(0xFF764ba2).withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: Color(0xFF667eea),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'AI is analyzing your wardrobe...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: GlamoraColors.deepNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Creating personalized recommendations',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation(Color(0xFF667eea)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final outfitSuggestions = _recommendations!['outfitSuggestions'] as List? ?? [];
    final missingItems = _recommendations!['missingItems'] as List? ?? [];
    final styleInsights = _recommendations!['styleInsights'] as List? ?? [];
    final colorAdvice = _recommendations!['colorAdvice'] as String? ?? '';
    final seasonalTips = _recommendations!['seasonalTips'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Outfit Suggestions
          if (outfitSuggestions.isNotEmpty) ...[
            _buildSectionTitle('Outfit Suggestions', Icons.checkroom_rounded),
            const SizedBox(height: 12),
            ...outfitSuggestions.map((outfit) => _buildOutfitCard(outfit as Map<String, dynamic>)),
            const SizedBox(height: 24),
          ],

          // Style Insights
          if (styleInsights.isNotEmpty) ...[
            _buildSectionTitle('Style Insights', Icons.lightbulb_rounded),
            const SizedBox(height: 12),
            _buildInsightsCard(styleInsights.cast<String>()),
            const SizedBox(height: 24),
          ],

          // Color Advice
          if (colorAdvice.isNotEmpty) ...[
            _buildSectionTitle('Color Palette Advice', Icons.palette_rounded),
            const SizedBox(height: 12),
            _buildAdviceCard(colorAdvice, Icons.color_lens, const Color(0xFFE91E63)),
            const SizedBox(height: 24),
          ],

          // Missing Items
          if (missingItems.isNotEmpty) ...[
            _buildSectionTitle('Recommended Additions', Icons.add_shopping_cart_rounded),
            const SizedBox(height: 12),
            _buildMissingItemsCard(missingItems.cast<String>()),
            const SizedBox(height: 24),
          ],

          // Seasonal Tips
          if (seasonalTips.isNotEmpty) ...[
            _buildSectionTitle('Seasonal Tips', Icons.wb_sunny_rounded),
            const SizedBox(height: 12),
            _buildAdviceCard(seasonalTips, Icons.calendar_today, const Color(0xFF4CAF50)),
            const SizedBox(height: 24),
          ],

          // Quick Outfit Button
          _buildQuickOutfitButton(),

          const SizedBox(height: 100),
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
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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

  Widget _buildOutfitCard(Map<String, dynamic> outfit) {
    final name = outfit['name'] as String? ?? 'Outfit';
    final items = (outfit['items'] as List?)?.cast<String>() ?? [];
    final occasion = outfit['occasion'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667eea).withOpacity(0.15),
                      const Color(0xFF764ba2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.style, color: Color(0xFF667eea), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GlamoraColors.deepNavy,
                      ),
                    ),
                    if (occasion.isNotEmpty)
                      Text(
                        occasion,
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF667eea).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.checkroom, size: 14, color: const Color(0xFF667eea).withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF667eea),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(List<String> insights) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea).withOpacity(0.08),
            const Color(0xFF764ba2).withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF667eea).withOpacity(0.15)),
      ),
      child: Column(
        children: insights.asMap().entries.map((entry) {
          final index = entry.key;
          final insight = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < insights.length - 1 ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    shape: BoxShape.circle,
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
                    insight,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
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

  Widget _buildAdviceCard(String advice, IconData icon, Color color) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              advice,
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

  Widget _buildMissingItemsCard(List<String> items) {
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
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFFFF9800), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
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

  Widget _buildQuickOutfitButton() {
    return GestureDetector(
      onTap: () async {
        // Show quick outfit dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const _QuickOutfitDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Outfit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get an instant outfit suggestion',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}

class _QuickOutfitDialog extends StatefulWidget {
  const _QuickOutfitDialog();

  @override
  State<_QuickOutfitDialog> createState() => _QuickOutfitDialogState();
}

class _QuickOutfitDialogState extends State<_QuickOutfitDialog> {
  Map<String, dynamic>? _outfit;
  bool _isLoading = true;
  String _selectedOccasion = 'Günlük';

  final occasions = ['Günlük', 'İş', 'Parti', 'Spor', 'Randevu'];

  @override
  void initState() {
    super.initState();
    _loadOutfit();
  }

  Future<void> _loadOutfit() async {
    setState(() => _isLoading = true);
    final outfit = await StyleCoachService.getQuickOutfitSuggestion(
      occasion: _selectedOccasion,
    );
    if (mounted) {
      setState(() {
        _outfit = outfit;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Quick Outfit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: GlamoraColors.deepNavy,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Occasion selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: occasions.map((occasion) {
                  final isSelected = occasion == _selectedOccasion;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedOccasion = occasion);
                        _loadOutfit();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                              ? const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])
                              : null,
                          color: isSelected ? null : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          occasion,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Content
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF667eea)),
                    SizedBox(height: 16),
                    Text('AI is thinking...'),
                  ],
                ),
              )
            else if (_outfit == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.checkroom, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Add items to your wardrobe first',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            else ...[
              // Outfit name
              Text(
                _outfit!['outfitName'] ?? 'Today\'s Outfit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: GlamoraColors.deepNavy,
                ),
              ),
              const SizedBox(height: 16),
              
              // Items
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: ((_outfit!['items'] as List?) ?? []).map<Widget>((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667eea).withOpacity(0.12),
                          const Color(0xFF764ba2).withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.checkroom, size: 16, color: Color(0xFF667eea)),
                        const SizedBox(width: 6),
                        Text(
                          item.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Reason
              if ((_outfit!['reason'] ?? '').isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.grey[500]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _outfit!['reason'],
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
