import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:palette_generator/palette_generator.dart';

/// Basit model: Dolaptaki öğenin görseli
class WardrobeItem {
  final ImageProvider image;   // AssetImage / NetworkImage / FileImage olabilir
  final String? title;
  WardrobeItem({required this.image, this.title});
}

class ColorDistributionPage extends StatefulWidget {
  final List<WardrobeItem> items;

  const ColorDistributionPage({super.key, required this.items});

  @override
  State<ColorDistributionPage> createState() => _ColorDistributionPageState();
}

class _ColorDistributionPageState extends State<ColorDistributionPage> {
  bool _loading = true;
  Map<String, int> _counts = {};
  Map<String, Color> _labelColors = {};

  @override
  void initState() {
    super.initState();
    _compute();
  }

  Future<void> _compute() async {
    final Map<String, int> counts = {};
    final Map<String, Color> labelColors = {};

    // Görsellerden baskın rengi çıkar
    for (final item in widget.items) {
      try {
        final palette = await PaletteGenerator.fromImageProvider(
          item.image,
          size: const Size(200, 200),
          maximumColorCount: 16,
        );
        final dominant = palette.dominantColor?.color;
        if (dominant == null) continue;

        final label = _colorLabel(dominant);
        counts[label] = (counts[label] ?? 0) + 1;

        // her label için temsili renk (ilk geleni kaydediyoruz)
        labelColors.putIfAbsent(label, () => dominant);
      } catch (_) {
        // görsel okunamadıysa geç
      }
    }

    setState(() {
      _counts = counts;
      _labelColors = labelColors;
      _loading = false;
    });
  }

  // ---- Renk etiketleme (HSV'ye göre) ----
  String _colorLabel(Color c) {
    final hsv = HSVColor.fromColor(c);
    final h = hsv.hue;           // 0..360
    final s = hsv.saturation;    // 0..1
    final v = hsv.value;         // 0..1

    // Açık/Koyu/Nötr kontrolleri
    if (v > 0.92 && s < 0.15) return 'White';
    if (v < 0.18) return 'Black';
    if (s < 0.15) return 'Grey';

    // Ton aralıkları (yaklaşık)
    if (h >= 0 && h < 15) return 'Red';
    if (h >= 15 && h < 35) return 'Orange';
    if (h >= 35 && h < 55) return 'Yellow';
    if (h >= 55 && h < 85) return 'Yellow-Green';
    if (h >= 85 && h < 160) return 'Green';
    if (h >= 160 && h < 200) return 'Cyan';
    if (h >= 200 && h < 250) return 'Blue';
    if (h >= 250 && h < 290) return 'Purple';
    if (h >= 290 && h < 330) return 'Pink';
    if (h >= 330 && h <= 360) return 'Red';

    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    final total = _counts.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Distribution'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : total == 0
              ? const Center(child: Text('No images to analyze yet.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // PIE CHART
                      SizedBox(
                        height: 260,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: _counts.entries.map((e) {
                              final label = e.key;
                              final count = e.value;
                              final pct = (count / total) * 100.0;
                              final color = _labelColors[label] ?? Colors.grey;

                              return PieChartSectionData(
                                value: count.toDouble(),
                                title: '${pct.toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                color: color,
                                radius: 90,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // LEJANT + SAYILAR
                      Expanded(
                        child: ListView.separated(
                          itemCount: _counts.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: Theme.of(context).dividerColor),
                          itemBuilder: (context, idx) {
                            final entry = _counts.entries.elementAt(idx);
                            final label = entry.key;
                            final count = entry.value;
                            final pct = (count / total) * 100.0;

                            return Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _labelColors[label] ?? Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  '${count} items  •  ${pct.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
