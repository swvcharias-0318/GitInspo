import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_models.dart';
import '../services/firebase_service.dart';

class AppState extends ChangeNotifier {
  List<InspoPost> posts = List.of(demoPosts);
  List<InspoBoard> boards = const [
    InspoBoard(id: 'b1', name: 'Room ideas'),
    InspoBoard(id: 'b2', name: 'Recipes'),
    InspoBoard(id: 'b3', name: 'Weekend away'),
  ];
  final Map<String, String> savedPostBoards = {};
  final Set<String> likedPosts = {};
  String username = 'alex.morgan';
  String fullName = 'Alex Morgan';
  String email = '';
  String bio = 'Collecting little things that make a life.';
  String? uid;
  bool isAuthenticated = false;

  Future<void> loadRemotePosts() async {
    if (!FirebaseService.isReady) return;
    try {
      final remote = await FirebaseService.loadPosts();
      if (remote.isNotEmpty) posts = [...remote, ...posts];
    } catch (_) {}
  }

  Future<void> login(String emailAddress, String password) async {
    if (FirebaseService.isReady) {
      final credential = await FirebaseService.signIn(emailAddress, password);
      uid = credential.user?.uid;
      fullName = credential.user?.displayName ?? fullName;
      username = fullName.toLowerCase().replaceAll(' ', '.');
      await _loadUserCollections();
    }
    email = emailAddress;
    isAuthenticated = true;
    notifyListeners();
  }

  void continueAsGuest() {
    isAuthenticated = true;
    uid = null;
    notifyListeners();
  }

  Future<void> _loadUserCollections() async {
    final userId = uid;
    if (userId == null || !FirebaseService.isReady) return;
    try {
      final profile = await FirebaseService.loadProfile(userId);
      final remoteBoards = await FirebaseService.loadBoards(userId);
      final remoteSaves = await FirebaseService.loadSavedPosts(userId);
      if (profile != null) {
        username = profile['username'] as String? ?? username;
        bio = profile['bio'] as String? ?? bio;
        fullName = profile['fullName'] as String? ?? fullName;
      }
      if (remoteBoards.isNotEmpty) {
        boards = remoteBoards;
      } else {
        boards = [
          InspoBoard(id: '${userId}_room', name: 'Room ideas'),
          InspoBoard(id: '${userId}_recipes', name: 'Recipes'),
          InspoBoard(id: '${userId}_travel', name: 'Weekend away'),
        ];
        for (final board in boards) {
          await FirebaseService.createBoard(userId, board);
        }
      }
      savedPostBoards
        ..clear()
        ..addAll(remoteSaves);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> register({
    required String name,
    required String handle,
    required String emailAddress,
    required String password,
  }) async {
    fullName = name;
    username = handle;
    email = emailAddress;
    if (FirebaseService.isReady) {
      final credential = await FirebaseService.register(
        name: name,
        username: handle,
        email: emailAddress,
        password: password,
      );
      uid = credential.user?.uid;
      await _loadUserCollections();
    }
    isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    if (FirebaseService.isReady) await FirebaseService.signOut();
    uid = null;
    isAuthenticated = false;
    notifyListeners();
  }

  Future<void> toggleSave(InspoPost post, {String? boardId}) async {
    if (savedPostBoards.containsKey(post.id)) {
      savedPostBoards.remove(post.id);
      if (FirebaseService.isReady && uid != null) {
        await FirebaseService.removeSavedPost(uid!, post);
      }
    } else {
      final selectedBoard = boardId ?? (boards.isEmpty ? '' : boards.first.id);
      savedPostBoards[post.id] = selectedBoard;
      if (FirebaseService.isReady && uid != null) {
        await FirebaseService.savePost(uid!, post, selectedBoard);
      }
    }
    notifyListeners();
  }

  Future<void> toggleLike(InspoPost post) async {
    final liked = likedPosts.add(post.id);
    if (!liked) likedPosts.remove(post.id);
    if (FirebaseService.isReady && uid != null) {
      await FirebaseService.toggleLike(uid!, post, liked);
    }
    notifyListeners();
  }

  Future<void> addBoard(String name) async {
    final board = InspoBoard(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name);
    boards = [...boards, board];
    if (FirebaseService.isReady && uid != null) {
      await FirebaseService.createBoard(uid!, board);
    }
    notifyListeners();
  }

  Future<void> renameBoard(String id, String name) async {
    boards = boards.map((board) => board.id == id ? InspoBoard(id: id, name: name) : board).toList();
    if (FirebaseService.isReady && uid != null) await FirebaseService.updateBoard(id, name);
    notifyListeners();
  }

  Future<void> deleteBoard(String id) async {
    boards = boards.where((board) => board.id != id).toList();
    savedPostBoards.removeWhere((_, boardId) => boardId == id);
    if (FirebaseService.isReady && uid != null) await FirebaseService.deleteBoard(id);
    notifyListeners();
  }

  Future<void> addPost({
    required String title,
    required String description,
    required String category,
    required String boardId,
    required List<String> tags,
    required Uint8List imageBytes,
    XFile? imageFile,
  }) async {
    final postId = DateTime.now().microsecondsSinceEpoch.toString();
    final post = InspoPost(
      id: postId,
      title: title,
      creator: username,
      category: category,
      imageUrl: '',
      description: description,
      height: 260,
      tags: tags,
      imageBytes: imageBytes,
    );
    if (FirebaseService.isReady && uid != null) {
      await FirebaseService.createPost(
        postId: postId,
        uid: uid!,
        username: username,
        post: post,
        image: imageFile,
      );
      await FirebaseService.savePost(uid!, post, boardId);
    }
    posts = [post, ...posts];
    savedPostBoards[post.id] = boardId;
    notifyListeners();
  }

  Future<void> updateProfile({required String handle, required String about}) async {
    username = handle;
    bio = about;
    if (FirebaseService.isReady && uid != null) {
      await FirebaseService.updateProfile(uid: uid!, username: handle, bio: about);
    }
    notifyListeners();
  }
}