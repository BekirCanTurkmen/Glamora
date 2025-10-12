import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'photo_uploader.dart';
import '../theme/glamora_theme.dart';
import 'auth_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>> _outfits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No Supabase user logged in!');
      return;
    }

    try {
      final response = await _client
          .from('wardrobe')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _outfits = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading wardrobe: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlamoraColors.midnightBlue,
      appBar: AppBar(
        title: const Text("My Wardrobe"),
        centerTitle: true,
        backgroundColor: GlamoraColors.midnightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: GlamoraColors.creamBeige),
            onPressed: _loadOutfits,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: GlamoraColors.creamBeige),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: GlamoraColors.creamBeige),
      )
          : _outfits.isEmpty
          ? Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GlamoraColors.softWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "You haven’t added any outfits yet.\nTap the button below to add your first one.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GlamoraColors.creamBeige,
              fontSize: 16,
            ),
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: _outfits.length,
        itemBuilder: (context, index) {
          final outfit = _outfits[index];
          return GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(outfit['image_url'],
                      fit: BoxFit.cover),
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: GlamoraColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  outfit['image_url'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                  progress == null
                      ? child
                      : const Center(
                    child: CircularProgressIndicator(
                      color: GlamoraColors.creamBeige,
                    ),
                  ),
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white38,
                    size: 40,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_a_photo),
        label: const Text("Add Outfit"),
        backgroundColor: GlamoraColors.creamBeige,
        foregroundColor: GlamoraColors.midnightBlue,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PhotoUploader()),
          );
          _loadOutfits();
        },
      ),
    );
  }
}
