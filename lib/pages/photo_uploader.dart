import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dolabim/services/storage_service.dart';
import '../theme/glamora_theme.dart';

class PhotoUploader extends StatefulWidget {
  const PhotoUploader({super.key});

  @override
  State<PhotoUploader> createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;
  String? _selectedCategory;

  // kategori listesi
  final List<String> _categories = [
    "Tops",
    "Bottoms",
    "Dresses",
    "Shoes",
    "Outerwear",
    "Accessories",
    "Others",
  ];

  // fotoğraf seçimi
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // firebase'e yükleme işlemi
  Future<void> _uploadImage() async {
    if (_selectedImage == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category and photo.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await StorageService.uploadOutfitImage(_selectedImage!, _selectedCategory!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Outfit uploaded successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Outfit Photo"), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // fotoğraf alanı
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: GlamoraColors.softWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: GlamoraColors.creamBeige.withOpacity(0.4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "No photo selected",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),

              const SizedBox(height: 24),

              // kategori seçimi
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: GlamoraColors.deepNavy,
                decoration: InputDecoration(
                  labelText: "Select Category",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: GlamoraColors.softWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                iconEnabledColor: GlamoraColors.creamBeige,
                items: _categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    style: const TextStyle(color: Colors.white),
                  ),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Take a Photo"),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image),
                label: const Text("Choose from Gallery"),
              ),
              const SizedBox(height: 30),

              // yükleme butonu
              if (_selectedImage != null)
                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlamoraColors.creamBeige,
                    foregroundColor: GlamoraColors.midnightBlue,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(
                      color: GlamoraColors.midnightBlue)
                      : const Text(
                    "Upload Outfit",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
