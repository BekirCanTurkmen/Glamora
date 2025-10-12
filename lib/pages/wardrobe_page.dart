import 'package:flutter/material.dart';
import 'photo_uploader.dart';
import '../theme/glamora_theme.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = GlamoraColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wardrobe"),
        centerTitle: true,
      ),
      body: Center(
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
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ),

      // bu buton yeni kıyafet fotoğrafı ekleme ekranını açıyor
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_a_photo),
        label: const Text("Add Outfit"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PhotoUploader()),
          );
        },
      ),
    );
  }
}
