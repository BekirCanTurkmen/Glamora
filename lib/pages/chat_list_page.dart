import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/glamora_theme.dart';
import 'chat_page.dart';
import '../services/chat_service.dart';
import 'add_friend_page.dart';
import 'dart:async';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _chatService = ChatService();
  String _searchQuery = '';

  bool _showToast = false;
  String _toastMessage = "";
  late AnimationController _toastController;
  late Animation<Offset> _toastOffset;

  @override
  void initState() {
    super.initState();
    _listenForFriendRequests();

    // 🔹 Toast animasyonu ayarı
    _toastController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _toastOffset =
        Tween<Offset>(begin: const Offset(0, -1.0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
          parent: _toastController,
          curve: Curves.easeOutCubic,
        ));
  }

  @override
  void dispose() {
    _toastController.dispose();
    super.dispose();
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
          _showAnimatedToast(change.doc.id);
        }
      }
    });
  }

  Future<void> _showAnimatedToast(String fromUid) async {
    final userDoc =
    await _firestore.collection('glamora_users').doc(fromUid).get();
    final data = userDoc.data() ?? {};
    final username = data['username'] ?? 'a user';

    setState(() {
      _toastMessage = "$username sent you a friend request 💌";
      _showToast = true;
    });

    _toastController.forward();

    // 3 saniye sonra otomatik olarak kapanır
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _toastController.reverse();
        Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _showToast = false);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: GlamoraColors.deepNavy,
        title: const Text(
          "Messages",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Add Friend',
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

      body: Stack(
        children: [
          // 🔹 Asıl içerik
          Column(
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
                    hintText: "Search username...",
                    hintStyle: const TextStyle(
                      color: GlamoraColors.deepNavy,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(Icons.search,
                        color: GlamoraColors.deepNavy),
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

                    final users = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final username = data['username'] ?? '';
                      final email = data['email'] ?? '';
                      final uid = data['uid'] ?? '';

                      if (username.isEmpty || uid == currentUser.uid) {
                        return false;
                      }

                      return _searchQuery.isEmpty ||
                          username.toLowerCase().contains(_searchQuery) ||
                          email.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (users.isEmpty) {
                      return const Center(
                        child: Text(
                          "No users available to message yet.\nYou can add friends from the top right 💬",
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
                            final chatId = _chatService.generateChatId(
                                currentUser.uid, uid);
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

          // 🔔 Üstten kayan Toast (Glamora Style)
          if (_showToast)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _toastOffset,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: GlamoraColors.deepNavy,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.favorite, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _toastMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          _toastController.reverse();
                          setState(() => _showToast = false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
