import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Global state untuk interaksi sosial
  final Set<int> _likedPostIds = {};
  final Set<int> _repostedPostIds = {};
  final Set<int> _savedPostIds = {};
  final Set<int> _followingUserIds = {};

  // Getter
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isLiked(int postId) => _likedPostIds.contains(postId);
  bool isReposted(int postId) => _repostedPostIds.contains(postId);
  bool isSaved(int postId) => _savedPostIds.contains(postId);
  bool isFollowing(int userId) => _followingUserIds.contains(userId);

  int getLikeCount(Post post) {
    final base = (post.id ?? 1) * 8;
    return isLiked(post.id ?? 0) ? base + 1 : base;
  }

  int getRepostCount(Post post) {
    final base = (post.id ?? 1) * 2;
    return isReposted(post.id ?? 0) ? base + 1 : base;
  }

  /// Mengambil semua data pengumuman dari API
  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _postService.getPosts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menambahkan pengumuman baru ke API dan state lokal
  Future<Post> addPost(Post newPost) async {
    try {
      final createdPost = await _postService.createPost(newPost);
      // Tambahkan post baru di paling atas timeline
      _posts.insert(0, createdPost);
      notifyListeners();
      return createdPost;
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle Suka (Love)
  void toggleLike(int postId) {
    if (_likedPostIds.contains(postId)) {
      _likedPostIds.remove(postId);
    } else {
      _likedPostIds.add(postId);
    }
    notifyListeners();
  }

  /// Toggle Repost (Posting Ulang)
  bool toggleRepost(int postId) {
    final willRepost = !_repostedPostIds.contains(postId);
    if (willRepost) {
      _repostedPostIds.add(postId);
    } else {
      _repostedPostIds.remove(postId);
    }
    notifyListeners();
    return willRepost;
  }

  /// Toggle Simpan (Bookmark / Markah)
  bool toggleSaved(int postId) {
    final willSave = !_savedPostIds.contains(postId);
    if (willSave) {
      _savedPostIds.add(postId);
    } else {
      _savedPostIds.remove(postId);
    }
    notifyListeners();
    return willSave;
  }

  /// Toggle Ikuti (Follow)
  bool toggleFollow(int userId) {
    final willFollow = !_followingUserIds.contains(userId);
    if (willFollow) {
      _followingUserIds.add(userId);
    } else {
      _followingUserIds.remove(userId);
    }
    notifyListeners();
    return willFollow;
  }
}
