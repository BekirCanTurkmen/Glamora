import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? imageUrl;

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
    );
  }
}
