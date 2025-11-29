import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ai_service.dart';
import '../theme/glamora_theme.dart';

class AiChatPage extends StatefulWidget {
  // 🔥 YENİ: Dışarıdan otomatik mesaj alabilir
  final String? initialPrompt; 

  const AiChatPage({super.key, this.initialPrompt});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, String>> _messages = [
    {"sender": "ai", "text": "Selam! Ben Glamora Stilist. Dolabındaki kıyafetleri biliyorum. Bugün ne giymek istersin?"}
  ];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 🚀 EĞER DIŞARIDAN MESAJ GELDİYSE OTOMATİK BAŞLAT
    if (widget.initialPrompt != null) {
      // Sayfa çizildikten hemen sonra çalışsın diye gecikme veriyoruz
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendAutoMessage(widget.initialPrompt!);
      });
    }
  }

  // Otomatik mesaj gönderme (Kullanıcı baloncuğu oluşturmadan direkt sorgu yapar)
  Future<void> _sendAutoMessage(String prompt) async {
    setState(() {
      _isLoading = true;
      // İstersen promptu ekranda gösterebilirsin ama çok uzun olduğu için gizli tutmak daha şık olabilir.
      // Şimdilik kullanıcı sormuş gibi gösterelim:
      _messages.add({"sender": "user", "text": "Bana bugünkü verilerime göre bir kombin öner."}); 
    });
    _scrollToBottom();

    final response = await AiService.askGemini(prompt);

    setState(() {
      _messages.add({"sender": "ai", "text": response ?? "Bir hata oluştu."});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  /// 👗 Dolap verisi çekme (Normal sohbet için)
  Future<String> _getWardrobeContext() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return "Kullanıcı bilgisi bulunamadı.";

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('glamora_users') // 'users' ise değiştir
          .doc(uid)
          .collection('wardrobe')
          .get();

      if (snapshot.docs.isEmpty) return "Dolabım şu an boş.";

      List<String> items = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        items.add("- ${data['category'] ?? 'Eşya'} (${data['colorLabel'] ?? '?'})");
      }
      return items.join("\n");
    } catch (e) {
      return "Dolap verisi alınamadı.";
    }
  }

  // Normal manuel mesaj gönderme
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final wardrobeString = await _getWardrobeContext();
    
    final fullPrompt = """
    Sen kişisel bir moda asistanısın. Benim gardırobumda şu kıyafetler var:
    $wardrobeString
    
    Kullanıcı sorusu: "$text"
    """;

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
                      color: isUser ? GlamoraColors.deepNavy : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.4,
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

          // Input Area
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Bir şeyler sor...",
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: GlamoraColors.deepNavy),
                    onPressed: _sendMessage,
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