import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Mesaj gönderme
  Future<void> sendMessage(String chatId, Message message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // Son mesaj bilgilerini güncelle
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp,
    }, SetOptions(merge: true));
  }

  /// 🔹 Mesajları dinleme (gerçek zamanlı)
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  /// 🔹 İki kullanıcı arasındaki sabit chat ID'yi üretir
  String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort(); // UID’leri alfabetik sıraya koy
    return '${sorted[0]}_${sorted[1]}';
  }

  /// 🔹 Eğer chat dokümanı yoksa Firestore’a ekle
  Future<void> createChatIfNotExists(String chatId, String uid1, String uid2) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final doc = await chatRef.get();

    if (!doc.exists) {
      await chatRef.set({
        'participants': [uid1, uid2],
        'lastMessage': '',
        'lastMessageTime': DateTime.now(),
      });
    }
  }
}
