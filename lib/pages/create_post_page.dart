import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/glamora_theme.dart';
import '../services/feed_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  File? _selectedImage;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isUploading = false;
  double _uploadProgress = 0;
  
  // Wardrobe selection
  String? _selectedWardrobeImageUrl;
  String? _selectedWardrobeItemId;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _selectedWardrobeImageUrl = null;
        _selectedWardrobeItemId = null;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _selectedWardrobeImageUrl = null;
        _selectedWardrobeItemId = null;
      });
    }
  }

  Future<void> _pickFromWardrobe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select from Wardrobe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: GlamoraColors.deepNavy,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('glamora_users')
                    .doc(user.uid)
                    .collection('wardrobe')
                    .orderBy('uploadedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data!.docs;

                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No items in your wardrobe'),
                    );
                  }

                  return GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index].data() as Map<String, dynamic>;
                      final imageUrl = (item['imageUrl'] ?? '').toString();

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(bottomSheetContext, {
                            'imageUrl': imageUrl,
                            'itemId': items[index].id,
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedWardrobeImageUrl = result['imageUrl']?.toString();
        _selectedWardrobeItemId = result['itemId']?.toString();
        _selectedImage = null;
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedImage == null && _selectedWardrobeImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      String imageUrl;

      if (_selectedWardrobeImageUrl != null) {
        // Use existing wardrobe image
        imageUrl = _selectedWardrobeImageUrl!;
      } else {
        // Upload new image
        final user = FirebaseAuth.instance.currentUser!;
        final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance
            .ref()
            .child('feed_posts')
            .child(user.uid)
            .child(fileName);

        final uploadTask = ref.putFile(_selectedImage!);

        uploadTask.snapshotEvents.listen((event) {
          setState(() {
            _uploadProgress = event.bytesTransferred / event.totalBytes;
          });
        });

        await uploadTask;
        imageUrl = await ref.getDownloadURL();
      }

      // Parse tags
      final tags = _tagsController.text
          .split(RegExp(r'[,\s#]+'))
          .where((t) => t.trim().isNotEmpty)
          .map((t) => t.trim().toLowerCase())
          .toList();

      // Create post
      await FeedService.createPost(
        imageUrl: imageUrl,
        caption: _captionController.text.trim(),
        tags: tags,
        outfitItems: _selectedWardrobeItemId != null ? [_selectedWardrobeItemId!] : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post shared successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _selectedImage != null || _selectedWardrobeImageUrl != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: GlamoraColors.deepNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: hasImage && !_isUploading ? _uploadPost : null,
            child: Text(
              'Share',
              style: TextStyle(
                color: hasImage && !_isUploading
                    ? const Color(0xFF3897F0)
                    : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: _uploadProgress,
                          color: GlamoraColors.deepNavy,
                          strokeWidth: 4,
                        ),
                      ),
                      Text(
                        '${(_uploadProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: GlamoraColors.deepNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sharing your outfit...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Preview or Selector
                  if (!hasImage) ...[
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'Add a photo of your outfit',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SourceButton(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            onTap: _pickFromCamera,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SourceButton(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            onTap: _pickFromGallery,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SourceButton(
                            icon: Icons.checkroom,
                            label: 'Wardrobe',
                            onTap: _pickFromWardrobe,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : Image.network(_selectedWardrobeImageUrl!, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                                _selectedWardrobeImageUrl = null;
                                _selectedWardrobeItemId = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Caption
                  TextField(
                    controller: _captionController,
                    maxLines: 3,
                    maxLength: 200,
                    style: const TextStyle(
                      color: Color(0xFF1a1a1a), // Dark text color
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      counterStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF13224F), width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tags
                  TextField(
                    controller: _tagsController,
                    style: const TextStyle(
                      color: Color(0xFF1a1a1a), // Dark text color
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add tags (e.g., casual, summer, office)',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: Icon(Icons.tag, color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF13224F), width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GlamoraColors.deepNavy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: GlamoraColors.deepNavy.withOpacity(0.7)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Tip: Use good lighting and show your full outfit for more engagement!',
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF13224F).withOpacity(0.08),
              const Color(0xFF667eea).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF13224F).withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF13224F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF13224F), size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF13224F), // Explicit dark navy color
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
