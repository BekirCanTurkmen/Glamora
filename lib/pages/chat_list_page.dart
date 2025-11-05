import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/glamora_theme.dart';
import 'chat_page.dart';
import '../services/chat_service.dart';
import 'add_friend_page.dart';

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
  void initState() {
    super.initState();
    _listenForFriendRequests(); // 🔔 canlı bildirim
  }

  // 🔹 Yeni arkadaşlık isteği bildirimi dinleyicisi
  void _listenForFriendRequests() {
    final currentUser = _auth.currentUser!;
    _firestore
        .collection('glamora_users')
        .doc(currentUser.uid)
        .collection('friend_requests')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _showFriendRequestPopup(change.doc.id);
        }
      }
    });
  }

  Future<void> _showFriendRequestPopup(String fromUid) async {
    final userDoc =
    await _firestore.collection('glamora_users').doc(fromUid).get();
    final data = userDoc.data() ?? {};
    final username = data['username'] ?? 'Bilinmeyen kullanıcı';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text(
          "Yeni Arkadaşlık İsteği 💌",
          style: TextStyle(
            color: GlamoraColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "$username sana arkadaşlık isteği gönderdi.",
          style: const TextStyle(color: GlamoraColors.deepNavy, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Kapat",
              style: TextStyle(color: GlamoraColors.deepNavy),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: GlamoraColors.deepNavy,
        title: const Text(
          "Mesajlar",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Arkadaş Ekle',
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddFriendPage()),
              );
            },
          ),
        ],
      ),

      // 🔹 Ana içerik
      body: Column(
        children: [
          // 🔍 Arama kutusu
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: GlamoraColors.deepNavy,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Kullanıcı adı ara...",
                hintStyle: const TextStyle(
                  color: GlamoraColors.deepNavy,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon:
                const Icon(Icons.search, color: GlamoraColors.deepNavy),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: GlamoraColors.deepNavy,
                    width: 1.3,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: GlamoraColors.deepNavy,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // 👥 Kullanıcı listesi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('glamora_users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: GlamoraColors.deepNavy),
                  );
                }

                // 🔹 Kullanıcıları filtreleme (sadece username'i olanlar)
                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final username = data['username'] ?? '';
                  final email = data['email'] ?? '';
                  final uid = data['uid'] ?? '';

                  // username boşsa veya kendi UID'imizse gösterme
                  if (username.isEmpty || uid == currentUser.uid) return false;

                  return _searchQuery.isEmpty ||
                      username.toLowerCase().contains(_searchQuery) ||
                      email.toLowerCase().contains(_searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz mesajlaşabileceğin bir kullanıcı yok.\nSağ üstten arkadaş ekleyebilirsin 💬",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: GlamoraColors.deepNavy,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final data = users[index].data() as Map<String, dynamic>;
                    final username = data['username'];
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
                        _chatService.generateChatId(currentUser.uid, uid);
                        await _chatService.createChatIfNotExists(
                            chatId, currentUser.uid, uid);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatId: chatId,
                              currentUserId: currentUser.uid,
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
