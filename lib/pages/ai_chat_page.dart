import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ai_service.dart';
import '../theme/glamora_theme.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Başlangıç mesajı
  final List<Map<String, String>> _messages = [
    {"sender": "ai", "text": "Selam! Ben Glamora Stilist. Dolabındaki kıyafetleri biliyorum. Bugün ne giymek istersin?"}
  ];
  
  bool _isLoading = false;

  /// 👗 1. ADIM: Dolaptaki Kıyafetleri Metne Dönüştür
  Future<String> _getWardrobeContext() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return "Kullanıcı bilgisi bulunamadı.";

    try {
      // ⚠️ DİKKAT: Veritabanındaki koleksiyon adın 'users' ise burayı 'users' yap!
      final snapshot = await FirebaseFirestore.instance
          .collection('glamora_users') 
          .doc(uid)
          .collection('wardrobe')
          .get();

      if (snapshot.docs.isEmpty) return "Dolabım şu an boş.";

      List<String> items = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'Bilinmeyen Kategori';
        final color = data['colorLabel'] ?? 'Renk belirtilmemiş';
        items.add("- $category ($color)");
      }

      return items.join("\n");
    } catch (e) {
      return "Dolap verisi alınamadı.";
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 🧠 2. ADIM: Dolap bilgisini çek ve soruyla birleştir
    final wardrobeString = await _getWardrobeContext();
    
    final fullPrompt = """
    Sen kişisel bir moda asistanısın. Benim gardırobumda şu kıyafetler var:
    
    $wardrobeString
    
    Lütfen SADECE bu dolaptaki kıyafetleri veya bunlara çok uyumlu olabilecek parçaları kullanarak şu soruma cevap ver: 
    "$text"
    
    Cevabı kısa, samimi ve öneri odaklı ver.
    """;

    // 3. ADIM: Gemini'ye sor
    final response = await AiService.askGemini(fullPrompt);

    setState(() {
      _messages.add({"sender": "ai", "text": response ?? "Bir hata oluştu."});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Glamora AI Stylist", style: TextStyle(color: GlamoraColors.deepNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: GlamoraColors.deepNavy),
      ),
      body: Column(
        children: [
          // 💬 MESAJ LİSTESİ
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? GlamoraColors.deepNavy : const Color(0xFFF0F0F0), // AI rengi biraz daha koyu gri
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 3,
                           offset: const Offset(0, 1),
                         )
                      ]
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.4, // Satır aralığı okumayı kolaylaştırır
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LinearProgressIndicator(color: GlamoraColors.deepNavy, backgroundColor: Color(0xFFE0E0E0)),
            ),

          // ⌨️ YAZI YAZMA ALANI (DÜZELTİLDİ)
          SafeArea( // ✅ Alttan çentik payı bırakır
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)), // Üste ince çizgi
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5)
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 3, // Çok satırlı yazmaya izin verir
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Örn: Yarın ne giyeyim?",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5), // Hafif gri arka plan
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey.shade300), // Kenarlık rengi
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: GlamoraColors.deepNavy), // Tıklanınca lacivert olsun
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Gönder Butonu
                  Container(
                    decoration: const BoxDecoration(
                      color: GlamoraColors.deepNavy,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}