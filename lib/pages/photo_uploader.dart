import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/glamora_theme.dart';

class PhotoUploader extends StatefulWidget {
  const PhotoUploader({super.key});

  @override
  State<PhotoUploader> createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader> {
  final SupabaseClient _client = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool isUploading = false;
  final TextEditingController _categoryController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  /// 🌟 Upload Outfit with Supabase + Glamora Popup Dialogs
  Future<void> _uploadOutfit() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      _showDialog("Login Required",
          "You must be logged in before uploading an outfit.");
      return;
    }

    if (_selectedImage == null) {
      _showDialog("No Photo Selected",
          "Please select or take a photo before uploading your outfit.");
      return;
    }

    setState(() => isUploading = true);
    final userId = user.id;
    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.path.split('/').last}";

    try {
      // 1️⃣ Upload to Supabase Storage
      await _client.storage
          .from('wardrobe')
          .upload('users/$userId/$fileName', _selectedImage!);

      final publicUrl = _client.storage
          .from('wardrobe')
          .getPublicUrl('users/$userId/$fileName');

      // 2️⃣ Save metadata to Supabase DB
      await _client.from('wardrobe').insert({
        'user_id': userId,
        'image_url': publicUrl,
        'category': _categoryController.text.isEmpty
            ? 'Uncategorized'
            : _categoryController.text,
        'created_at': DateTime.now().toIso8601String(),
      });

      // ✅ Success
      _showDialog("Upload Successful",
          "Your outfit has been uploaded successfully!", popTwice: true);
    } catch (e) {
      debugPrint("❌ Upload failed: $e");
      _showDialog("Upload Failed",
          "Something went wrong while uploading. Please try again.");
    }

    setState(() => isUploading = false);
  }

  /// 🎨 Reusable Glamora-styled dialog
  void _showDialog(String title, String message, {bool popTwice = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GlamoraColors.midnightBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: GlamoraColors.creamBeige,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (popTwice) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GlamoraColors.creamBeige,
              foregroundColor: GlamoraColors.midnightBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlamoraColors.midnightBlue,
      appBar: AppBar(
        title: const Text("Add Outfit Photo"),
        backgroundColor: GlamoraColors.midnightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
                ),
                alignment: Alignment.center,
                child: const Text(
                  "No photo selected",
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _categoryController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Category (optional)",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: GlamoraColors.softWhite,
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(color: GlamoraColors.creamBeige, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(color: GlamoraColors.creamBeige, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Take Photo"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image),
              label: const Text("Choose from Gallery"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isUploading ? null : _uploadOutfit,
              style: ElevatedButton.styleFrom(
                backgroundColor: GlamoraColors.creamBeige,
                foregroundColor: GlamoraColors.midnightBlue,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: isUploading
                  ? const CircularProgressIndicator(
                  color: GlamoraColors.midnightBlue)
                  : const Text("Upload Outfit"),
            ),
          ],
        ),
      ),
    );
  }
}
