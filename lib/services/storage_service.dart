import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  // outfit görselini Firebase Storage'a yükler ve Firestore'a kaydeder
  static Future<void> uploadOutfitImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // storage yolu: users/{uid}/wardrobe/timestamp.jpg
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('wardrobe')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    // dosyayı Firebase Storage'a yükleme
    final uploadTask = await storageRef.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Firestore'a kayıt
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe')
        .add({
      'imageUrl': downloadUrl,
      'uploadedAt': Timestamp.now(),
    });
  }

  // outfit silme (Firestore + Storage)
  static Future<void> deleteOutfit(String docId, String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // Firestore'dan belgeyi sil
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wardrobe')
        .doc(docId)
        .delete();

    // Storage'tan da aynı dosyayı sil
    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();
  }

  // ileride kullanılacak: ana sayfaya (trends koleksiyonu) paylaşım
  static Future<void> shareToTrends(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('trends').add({
      'imageUrl': imageUrl,
      'userId': user.uid,
      'sharedAt': Timestamp.now(),
    });
  }
}
