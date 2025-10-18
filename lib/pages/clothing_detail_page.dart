import 'package:flutter/material.dart';
import '../theme/glamora_theme.dart';

class ClothingDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ClothingDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final imageUrl = data['imageUrl'] ?? '';
    final category = data['category'] ?? 'Unknown';
    final colors = data['colors'] != null
        ? List<String>.from(data['colors'])
        : data['colorLabel'] != null
        ? [data['colorLabel']]
        : [];
    final tags = List<String>.from(data['tags'] ?? []);
    final datePurchased = data['datePurchased'] ?? '-';
    final brand = data['brand'] ?? '-';
    final size = data['size'] ?? '-';
    final price = data['price'] ?? '-';
    final season = data['season'] ?? '-';
    final state = data['state'] ?? '-';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: GlamoraColors.deepNavy),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.info_outline, color: GlamoraColors.deepNavy),
          SizedBox(width: 8),
          Icon(Icons.send_outlined, color: GlamoraColors.deepNavy),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.white, // ✅ Beyaz arka plan
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRow("Category", category),
                _buildRow("Brand", brand),
                _buildRow("Size", size),
                _buildRow("Price", price),
                _buildRow("Season", season),
                _buildRow("State", state),
                _buildRow("Date Purchased", datePurchased),
                const SizedBox(height: 12),

                const Text("Colours",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: GlamoraColors.deepNavy)),
                const SizedBox(height: 6),
                if (colors.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children:
                    colors.map((c) => Chip(label: Text(c))).toList(),
                  )
                else
                  const Text("-", style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 12),

                const Text("Tags",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: GlamoraColors.deepNavy)),
                const SizedBox(height: 6),
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: tags
                        .map((t) => Chip(
                      label: Text(t),
                      backgroundColor: GlamoraColors.creamBeige,
                    ))
                        .toList(),
                  )
                else
                  const Text("-", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: GlamoraColors.deepNavy)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
