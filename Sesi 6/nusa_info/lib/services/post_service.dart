import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Mengambil semua data pengumuman (GET /posts)
  Future<List<Post>> getPosts() async {
    // 1. Buat alamat
    final Uri url = Uri.parse('$_baseUrl/posts');

    // 2. Kirim request
    final http.Response response = await http.get(url);

    // 3. Cek status code
    if (response.statusCode == 200) {
      // 4. Ubah JSON menjadi objek
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((item) => Post.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat pengumuman. Kode status: ${response.statusCode}');
    }
  }

  /// Mengambil komentar berdasarkan ID pengumuman (GET /posts/{id}/comments)
  Future<List<Comment>> getComments(int postId) async {
    // 1. Buat alamat
    final Uri url = Uri.parse('$_baseUrl/posts/$postId/comments');

    // 2. Kirim request
    final http.Response response = await http.get(url);

    // 3. Cek status code
    if (response.statusCode == 200) {
      // 4. Ubah JSON menjadi objek
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((item) => Comment.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat komentar. Kode status: ${response.statusCode}');
    }
  }

  /// Menambahkan pengumuman baru (POST /posts)
  Future<Post> createPost(Post post) async {
    // 1. Buat alamat
    final Uri url = Uri.parse('$_baseUrl/posts');

    // 2. Kirim request
    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(post.toJson()),
    );

    // 3. Cek status code
    if (response.statusCode == 201 || response.statusCode == 200) {
      // 4. Ubah JSON menjadi objek
      final Map<String, dynamic> jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return Post.fromJson(jsonMap);
    } else {
      throw Exception('Gagal menambahkan pengumuman. Kode status: ${response.statusCode}');
    }
  }
}
