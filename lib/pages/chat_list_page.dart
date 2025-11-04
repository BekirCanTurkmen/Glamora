import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/glamora_theme.dart';
import 'chat_page.dart';
import '../services/chat_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _chatService = ChatService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: GlamoraColors.deepNavy,
        title: const Text("Mesajlar",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔹 Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Kullanıcı adı ara...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: GlamoraColors.deepNavy),
                filled: true,
                fillColor: GlamoraColors.softWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: GlamoraColors.deepNavy, width: 1.2),
                ),
              ),
            ),
          ),

          // 🔹 Kullanıcı listesi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('glamora_users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: GlamoraColors.deepNavy),
                  );
                }

                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final username = data['username'] ?? '';
                  final email = data['email'] ?? '';
                  final uid = data['uid'] ?? '';

                  return uid != _auth.currentUser!.uid &&
                      (_searchQuery.isEmpty ||
                          username.toLowerCase().contains(_searchQuery) ||
                          email.toLowerCase().contains(_searchQuery));
                }).toList();

                // 🔸 Eğer hiç kullanıcı yoksa:
                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      "Hiç arkadaşın yok.\nYeni kullanıcı adlarını arayabilirsin 💬",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: GlamoraColors.deepNavy,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  );
                }

                // 🔹 Normal listeleme
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final data = users[index].data() as Map<String, dynamic>;
                    final username = data['username'] ?? '(tanımsız kullanıcı)';
                    final email = data['email'] ?? '';
                    final uid = data['uid'] ?? '';

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: GlamoraColors.deepNavy,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        username,
                        style: const TextStyle(
                          color: GlamoraColors.deepNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(email),
                      onTap: () async {
                        final chatId =
                        _chatService.generateChatId(_auth.currentUser!.uid, uid);
                        await _chatService.createChatIfNotExists(
                            chatId, _auth.currentUser!.uid, uid);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatId: chatId,
                              currentUserId: _auth.currentUser!.uid,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
