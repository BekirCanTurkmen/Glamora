import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ==================== POSTS ====================

  /// Yeni post oluştur
  static Future<void> createPost({
    required String imageUrl,
    required String caption,
    List<String>? tags,
    List<String>? outfitItems,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Kullanıcı bilgilerini al
    final userDoc = await _firestore.collection('glamora_users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    await _firestore.collection('feed_posts').add({
      'userId': user.uid,
      'username': userData['username'] ?? user.email?.split('@').first ?? 'Anonymous',
      'userAvatar': userData['avatarUrl'] ?? '',
      'imageUrl': imageUrl,
      'caption': caption,
      'tags': tags ?? [],
      'outfitItems': outfitItems ?? [],
      'likes': [],
      'likeCount': 0,
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Feed postlarını getir (sayfalama ile)
  static Stream<QuerySnapshot> getFeedPosts({int limit = 20}) {
    return _firestore
        .collection('feed_posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Daha fazla post yükle (pagination)
  static Future<QuerySnapshot> loadMorePosts({
    required DocumentSnapshot lastDoc,
    int limit = 20,
  }) {
    return _firestore
        .collection('feed_posts')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();
  }

  /// Kullanıcının postlarını getir
  static Stream<QuerySnapshot> getUserPosts(String userId) {
    return _firestore
        .collection('feed_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Post sil
  static Future<void> deletePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('feed_posts').doc(postId).get();
    if (doc.data()?['userId'] == user.uid) {
      await _firestore.collection('feed_posts').doc(postId).delete();
    }
  }

  // ==================== LIKES ====================

  /// Post beğen
  static Future<void> likePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = _firestore.collection('feed_posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (!snapshot.exists) return;

      final likes = List<String>.from(snapshot.data()?['likes'] ?? []);
      
      if (!likes.contains(user.uid)) {
        likes.add(user.uid);
        transaction.update(postRef, {
          'likes': likes,
          'likeCount': likes.length,
        });
      }
    });
  }

  /// Post beğeniyi kaldır
  static Future<void> unlikePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = _firestore.collection('feed_posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (!snapshot.exists) return;

      final likes = List<String>.from(snapshot.data()?['likes'] ?? []);
      
      if (likes.contains(user.uid)) {
        likes.remove(user.uid);
        transaction.update(postRef, {
          'likes': likes,
          'likeCount': likes.length,
        });
      }
    });
  }

  /// Kullanıcı postu beğenmiş mi?
  static bool hasUserLiked(List<dynamic> likes) {
    final user = _auth.currentUser;
    if (user == null) return false;
    return likes.contains(user.uid);
  }

  // ==================== COMMENTS ====================

  /// Yorum ekle
  static Future<void> addComment(String postId, String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Kullanıcı bilgilerini al
    final userDoc = await _firestore.collection('glamora_users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    // Yorum ekle
    await _firestore
        .collection('feed_posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': user.uid,
      'username': userData['username'] ?? user.email?.split('@').first ?? 'Anonymous',
      'userAvatar': userData['avatarUrl'] ?? '',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Comment count'u güncelle
    await _firestore.collection('feed_posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  /// Yorumları getir
  static Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection('feed_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Yorum sil
  static Future<void> deleteComment(String postId, String commentId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final commentRef = _firestore
        .collection('feed_posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final doc = await commentRef.get();
    if (doc.data()?['userId'] == user.uid) {
      await commentRef.delete();
      
      // Comment count'u güncelle
      await _firestore.collection('feed_posts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });
    }
  }

  // ==================== USER PROFILE ====================

  /// Kullanıcı profilini güncelle
  static Future<void> updateUserProfile({
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    if (updates.isNotEmpty) {
      await _firestore.collection('glamora_users').doc(user.uid).update(updates);
    }
  }

  /// Kullanıcı profil bilgilerini getir
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final doc = await _firestore.collection('glamora_users').doc(userId).get();
    return doc.data() ?? {};
  }

  /// Kullanıcının post sayısını getir
  static Future<int> getUserPostCount(String userId) async {
    final snapshot = await _firestore
        .collection('feed_posts')
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
