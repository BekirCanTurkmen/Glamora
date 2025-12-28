import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/glamora_theme.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _controller = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _loading = false;

  Future<void> _sendFriendRequest() async {
    final username = _controller.text.trim().toLowerCase();
    if (username.isEmpty) return;

    setState(() => _loading = true);

    final currentUser = _auth.currentUser!;
    final userQuery = await _firestore
        .collection('glamora_users')
        .where('username', isEqualTo: username)
        .get();

    if (userQuery.docs.isEmpty) {
      _showSnackBar("User not found ❌", isError: true);
      setState(() => _loading = false);
      return;
    }

    final targetUser = userQuery.docs.first;
    final targetUid = targetUser.id;

    if (targetUid == currentUser.uid) {
      _showSnackBar("You can't send a request to yourself 🙃", isError: true);
      setState(() => _loading = false);
      return;
    }

    await _firestore
        .collection('glamora_users')
        .doc(targetUid)
        .collection('friend_requests')
        .doc(currentUser.uid)
        .set({
      'from': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('glamora_users')
        .doc(currentUser.uid)
        .collection('sent_requests')
        .doc(targetUid)
        .set({
      'to': targetUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _showSnackBar("Friend request sent ✅");
    _controller.clear();
    setState(() => _loading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
        isError ? const Color(0xFFB33A3A) : GlamoraColors.deepNavy,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: GlamoraColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Add Friend",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Enter your friend's username:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: GlamoraColors.deepNavy,
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 TextField
            TextField(
              controller: _controller,
              style: const TextStyle(
                color: GlamoraColors.deepNavy,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "e.g.: glamora_mer",
                hintStyle: const TextStyle(
                  color: GlamoraColors.deepNavy,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(Icons.person_add_alt_1,
                    color: GlamoraColors.deepNavy),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: GlamoraColors.deepNavy,
                    width: 1.3,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: GlamoraColors.deepNavy,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // 🔹 Gönder Butonu
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendFriendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlamoraColors.deepNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: _loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  "Send Request",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
