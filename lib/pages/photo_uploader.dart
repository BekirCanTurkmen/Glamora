import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palette_generator/palette_generator.dart';
import '../theme/glamora_theme.dart';

class PhotoUploader extends StatefulWidget {
  const PhotoUploader({super.key});

  @override
  State<PhotoUploader> createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader> {
  File? _selectedImage;
  bool _uploading = false;
  String? _selectedCategory;

  final List<String> _categories = [
    "Tops",
    "Bottoms",
    "Dresses",
    "Shoes",
    "Outerwear",
    "Accessories",
    "Others",
  ];

  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _uploadToFirebase() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a photo first.")),
      );
      return;
    }

    setState(() => _uploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");

      // 🔹 1️⃣ Fotoğrafı Storage’a yükle
      final fileName =
          "outfit_${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

      final ref = FirebaseStorage.instance
          .ref()
          .child('glamora_users') // ✅ Storage path de glamora_users
          .child(user.uid)
          .child('wardrobe')
          .child(fileName);

      await ref.putFile(_selectedImage!);
      final downloadUrl = await ref.getDownloadURL();

      // 🔹 2️⃣ Fotoğrafın baskın rengini analiz et
      final colorLabel = await _detectColorLabel(downloadUrl);

      // 🔹 3️⃣ Firestore’a kaydet
      await FirebaseFirestore.instance
          .collection('glamora_users') // ✅ Firestore path düzeltildi
          .doc(user.uid)
          .collection('wardrobe')
          .add({
        'imageUrl': downloadUrl,
        'uploadedAt': Timestamp.now(),
        'category': _selectedCategory ?? "Uncategorized",
        'colorLabel': colorLabel,
      });

      // 🔹 4️⃣ Başarı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload complete! Detected color: $colorLabel"),
          backgroundColor: GlamoraColors.deepNavy,
        ),
      );

      setState(() {
        _selectedImage = null;
        _selectedCategory = null;
        _uploading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // 🔹 Fotoğrafın baskın rengini tespit et
  Future<String> _detectColorLabel(String imageUrl) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(200, 200),
        maximumColorCount: 32,
      );

      final dominant = palette.dominantColor?.color ?? const Color(0xFF808080);
      final hsv = HSVColor.fromColor(dominant);
      final h = hsv.hue;
      final s = hsv.saturation;
      final v = hsv.value;

      if (v > 0.92 && s < 0.15) return 'White';
      if (v < 0.18) return 'Black';
      if (s < 0.15) return 'Gray';
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
    } catch (e) {
      print("⚠️ Palette error: $e");
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Add Outfit",
          style: TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Fotoğraf kutusu (beyaz zeminli)
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.white,
                    child: Image.file(
                      _selectedImage!,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              else
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    border: Border.all(
                      color: GlamoraColors.deepNavy.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Select an outfit photo",
                      style: TextStyle(color: GlamoraColors.deepNavy),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // 🔹 Kategori seçimi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),

              const SizedBox(height: 30),

              // 🔹 Butonlar
              if (!_uploading)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlamoraColors.creamBeige,
                        foregroundColor: GlamoraColors.deepNavy,
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text("Take Photo"),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlamoraColors.creamBeige,
                        foregroundColor: GlamoraColors.deepNavy,
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text("Choose"),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlamoraColors.deepNavy,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _uploadToFirebase,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text("Upload"),
                    ),
                  ],
                )
              else
                Column(
                  children: const [
                    SizedBox(height: 30),
                    CircularProgressIndicator(color: GlamoraColors.deepNavy),
                    SizedBox(height: 10),
                    Text(
                      "Uploading...",
                      style: TextStyle(color: GlamoraColors.deepNavy),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
