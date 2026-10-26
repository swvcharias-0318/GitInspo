import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_models.dart';

class FirebaseService {
  static bool isReady = false;

  static Future<UserCredential> signIn(String email, String password) =>
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  static Future<UserCredential> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'fullName': name,
      'username': username,
      'email': email,
      'bio': '',
      'profileImage': '',
      'followers': 0,
      'following': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return credential;
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  static Future<void> sendPasswordReset(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);

  static Future<List<InspoPost>> loadPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(60)
        .get();
    return snapshot.docs
        .map((doc) => InspoPost.fromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<List<InspoBoard>> loadBoards(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('boards')
        .where('userId', isEqualTo: uid)
        .get();
    return snapshot.docs
        .map((doc) => InspoBoard(id: doc.id, name: doc.data()['name'] as String? ?? 'Untitled board'))
        .toList();
  }

  static Future<Map<String, dynamic>?> loadProfile(String uid) async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return snapshot.data();
  }

  static Future<Map<String, String>> loadSavedPosts(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('savedPosts')
        .where('userId', isEqualTo: uid)
        .get();
    return {
      for (final doc in snapshot.docs)
        doc.data()['postId'] as String: doc.data()['boardId'] as String? ?? '',
    };
  }

  static Future<void> savePost(String uid, InspoPost post, String boardId) =>
      FirebaseFirestore.instance
          .collection('savedPosts')
          .doc('${uid}_${post.id}')
          .set({
            'userId': uid,
            'postId': post.id,
            'boardId': boardId,
            'createdAt': FieldValue.serverTimestamp(),
          });

  static Future<void> removeSavedPost(String uid, InspoPost post) =>
      FirebaseFirestore.instance
          .collection('savedPosts')
          .doc('${uid}_${post.id}')
          .delete();

  static Future<void> toggleLike(String uid, InspoPost post, bool liked) =>
      FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .collection('likes')
          .doc(uid)
          .set({'userId': uid, 'liked': liked});

  static Future<void> createBoard(String uid, InspoBoard board) =>
      FirebaseFirestore.instance.collection('boards').doc(board.id).set({
        'boardId': board.id,
        'userId': uid,
        'name': board.name,
        'description': board.description,
        'createdAt': FieldValue.serverTimestamp(),
      });

  static Future<void> updateBoard(String boardId, String name) =>
      FirebaseFirestore.instance.collection('boards').doc(boardId).update({'name': name});

  static Future<void> deleteBoard(String boardId) =>
      FirebaseFirestore.instance.collection('boards').doc(boardId).delete();

  static Future<String?> uploadImage(String uid, String postId, Uint8List bytes) async {
    final reference = FirebaseStorage.instance.ref('posts/$uid/$postId.jpg');
    await reference.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return reference.getDownloadURL();
  }

  static Future<void> createPost({
    required String postId,
    required String uid,
    required String username,
    required InspoPost post,
    XFile? image,
  }) async {
    var imageUrl = post.imageUrl;
    if (image != null) {
      imageUrl = await uploadImage(uid, postId, await image.readAsBytes()) ?? imageUrl;
    }
    await FirebaseFirestore.instance.collection('posts').doc(postId).set({
      'postId': postId,
      'userId': uid,
      'username': username,
      'imageUrl': imageUrl,
      'title': post.title,
      'description': post.description,
      'category': post.category,
      'tags': post.tags,
      'height': post.height,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateProfile({
    required String uid,
    required String username,
    required String bio,
  }) => FirebaseFirestore.instance.collection('users').doc(uid).set({
    'username': username,
    'bio': bio,
  }, SetOptions(merge: true));
}