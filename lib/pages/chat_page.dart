import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/glamora_theme.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlamoraColors.deepNavy,
      appBar: AppBar(
        backgroundColor: GlamoraColors.deepNavy,
        title: const Text(
          "Chat",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 Mesaj Listesi
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(color: GlamoraColors.champagne),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz mesaj yok.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUserId;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMe
                              ? GlamoraColors.champagne
                              : GlamoraColors.softWhite.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: isMe
                                ? GlamoraColors.deepNavy
                                : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔹 Mesaj Yazma Alanı (sadece chatId varsa)
          if (widget.chatId.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: GlamoraColors.deepNavy,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: GlamoraColors.champagne,
                        decoration: InputDecoration(
                          hintText: "Mesaj yaz...",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                            const BorderSide(color: Colors.white38, width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send,
                          color: GlamoraColors.champagne),
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = Message(
      text: text,
      senderId: widget.currentUserId,
      timestamp: DateTime.now(),
    );

    await _chatService.sendMessage(widget.chatId, message);
    _controller.clear();
  }
}
