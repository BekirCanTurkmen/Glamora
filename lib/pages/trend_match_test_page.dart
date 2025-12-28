// lib/pages/trend_match_test_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrendMatchTestPage extends StatefulWidget {
  const TrendMatchTestPage({super.key});

  @override
  State<TrendMatchTestPage> createState() => _TrendMatchTestPageState();
}

class _TrendMatchTestPageState extends State<TrendMatchTestPage> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _wardrobe = [];
  List<Map<String, dynamic>> _trends = [];
  List<_Proposal> _proposals = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('No user session. Please log in.');
      }

      // 1) En güncel trend belgesini çek
      final trendSnap = await _db
          .collection('trends')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (trendSnap.docs.isEmpty) {
        throw Exception('No data in trends collection.');
      }

      final latest = trendSnap.docs.first.data();
      final items = (latest['items'] as List)
          .cast<Map>()
          .map((e) => {
                'name': (e['name'] ?? '').toString(),
                'score': (e['score'] ?? 0),
              })
          .toList();

      // 2) Kullanıcının gardırobunu çek
      final wardrobeSnap =
          await _db.collection('users/$uid/wardrobe').get();

      final wardrobe = wardrobeSnap.docs
          .map((d) => {
                'id': d.id,
                ...d.data(),
              })
          .toList();

      // 3) Basit eşleştirme
      final proposals = _buildProposals(items, wardrobe);

      setState(() {
        _trends = items;
        _wardrobe = wardrobe;
        _proposals = proposals;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<_Proposal> _buildProposals(
      List<Map<String, dynamic>> trends,
      List<Map<String, dynamic>> wardrobe,
      ) {
    // ufak yardımcı
    double scoreItem(String trendName, Map<String, dynamic> it) {
      final t = trendName.toLowerCase();
      final title = (it['title'] ?? '').toString().toLowerCase();
      final category = (it['category'] ?? '').toString().toLowerCase();
      final color = (it['color'] ?? '').toString().toLowerCase();
      final season = (it['season'] ?? 'all').toString().toLowerCase();
      final tags = (it['tags'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];

      double s = 0;
      final text = [title, category, color, season, ...tags].join(' ');

      if (text.contains(t)) s += 0.6;
      if (tags.any((x) => t.contains(x) || x.contains(t))) s += 0.3;
      if (season == 'all') s += 0.05;

      // çok basit renk ipuçları
      final colorMap = {
        'cargo': ['olive', 'khaki', 'green'],
        'denim': ['blue', 'navy'],
        'metallic': ['silver', 'gray', 'grey'],
        'floral': ['multi', 'pink', 'green'],
      };
      for (final key in colorMap.keys) {
        if (t.contains(key) && colorMap[key]!.contains(color)) {
          s += 0.1;
        }
      }
      if (s > 1) s = 1;
      return s;
    }

    // top/bottom/shoes/outer basit ayrımı
    bool _in(List<String> cats, String? c) => cats.contains((c ?? '').toLowerCase());
    final tops = wardrobe.where((i) => _in(['tshirt','gömlek','kazak','sweat','top'], i['category'])).toList();
    final bottoms = wardrobe.where((i) => _in(['pantolon','jean','etek','şort','bottom'], i['category'])).toList();
    final shoes = wardrobe.where((i) => _in(['ayakkabı','sneaker','bot','loafer','shoes'], i['category'])).toList();
    final outers = wardrobe.where((i) => _in(['ceket','mont','trençkot','hırka','outer'], i['category'])).toList();

    final List<_Proposal> result = [];

    for (final trend in trends.take(10)) {
      final tname = trend['name'] as String;

      Map<String, dynamic>? pickBest(List<Map<String, dynamic>> arr) {
        if (arr.isEmpty) return null;
        arr.sort((a,b) => scoreItem(tname, b).compareTo(scoreItem(tname, a)));
        final best = arr.first;
        final sc = scoreItem(tname, best);
        return sc > 0 ? best : null;
      }

      final top = pickBest(List.from(tops));
      final bottom = pickBest(List.from(bottoms));
      final shoe = pickBest(List.from(shoes));
      final outer = pickBest(List.from(outers));

      if (top != null && bottom != null && shoe != null) {
        final scores = <double>[
          scoreItem(tname, top),
          scoreItem(tname, bottom),
          scoreItem(tname, shoe),
          if (outer != null) scoreItem(tname, outer),
        ];
        final avg = scores.reduce((a,b)=>a+b) / scores.length;

        result.add(_Proposal(
          trend: tname,
          score: double.parse(avg.toStringAsFixed(3)),
          top: top,
          bottom: bottom,
          shoes: shoe,
          outer: outer,
        ));
      }
    }

    result.sort((a,b) => b.score.compareTo(a.score));
    return result;
  }

  Future<void> _saveOutfit(_Proposal p) async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('users/$uid/outfits').add({
      'trend': p.trend,
      'score': p.score,
      'items': {
        'top': p.top['id'],
        'bottom': p.bottom['id'],
        'shoes': p.shoes['id'],
        'outer': p.outer?['id'],
      },
      'rationale': 'Match with trend "${p.trend}" by tag/color/season.',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        appBar: _AppBarTitle(),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: const _AppBarTitle(),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: const _AppBarTitle(),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Trends (${_trends.length})',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: -8,
              children: _trends.take(10).map((t) {
                return Chip(label: Text(t['name']));
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Suggested Outfits (${_proposals.length})',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_proposals.isEmpty)
              const Text('No matches found yet. Add different categories to your wardrobe.'),
            ..._proposals.map((p) => _ProposalCard(
              p: p,
              onSave: () => _saveOutfit(p),
            )),
          ],
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarTitle();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Trend Match (Test)'));
  }
}

class _Proposal {
  final String trend;
  final double score;
  final Map<String, dynamic> top;
  final Map<String, dynamic> bottom;
  final Map<String, dynamic> shoes;
  final Map<String, dynamic>? outer;

  _Proposal({
    required this.trend,
    required this.score,
    required this.top,
    required this.bottom,
    required this.shoes,
    this.outer,
  });
}

class _ProposalCard extends StatelessWidget {
  final _Proposal p;
  final VoidCallback onSave;

  const _ProposalCard({required this.p, required this.onSave});

  Widget _line(String label, Map<String, dynamic> it) {
    final title = (it['title'] ?? '').toString();
    final category = (it['category'] ?? '').toString();
    final color = (it['color'] ?? '').toString();
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text('$title  ($category, $color)')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trend: ${p.trend}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Score: ${p.score}'),
            const Divider(height: 16),
            _line('Top', p.top),
            _line('Bottom', p.bottom),
            _line('Shoes', p.shoes),
            if (p.outer != null) _line('Outer', p.outer!),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
