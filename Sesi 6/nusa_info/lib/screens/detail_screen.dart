import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../services/post_service.dart';

class DetailScreen extends StatefulWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PostService _postService = PostService();
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    if (widget.post.id != null) {
      _commentsFuture = _postService.getComments(widget.post.id!);
    } else {
      _commentsFuture = Future.value([]);
    }
  }

  void _sharePost() {
    final postUrl = 'https://nusainfo.com/posts/${widget.post.id}';
    Clipboard.setData(ClipboardData(text: postUrl));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.link, color: Color(0xFF1D9BF0), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tautan disalin ke papan klip: $postUrl',
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16181C),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const xBlue = Color(0xFF1D9BF0);
    const xBorder = Color(0xFF2F3336);
    const xSubText = Color(0xFF71767B);

    final postId = widget.post.id ?? 0;
    final userId = widget.post.userId;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Postingan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          final isFollowing = provider.isFollowing(userId);
          final isLiked = provider.isLiked(postId);
          final isReposted = provider.isReposted(postId);
          final isSaved = provider.isSaved(postId);

          final likeCount = provider.getLikeCount(widget.post);
          final repostCount = provider.getRepostCount(widget.post);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Akun Pengirim & Tombol Follow Global
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: xBlue.withValues(alpha: 0.2),
                            child: Text(
                              'U${widget.post.userId}',
                              style: const TextStyle(
                                color: xBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Kontributor ${widget.post.userId}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, size: 16, color: xBlue),
                                  ],
                                ),
                                Text(
                                  '@user_${widget.post.userId}',
                                  style: const TextStyle(color: xSubText, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          // Tombol Follow Tersinkronisasi Global via Provider
                          InkWell(
                            onTap: () {
                              final willFollow = provider.toggleFollow(userId);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    willFollow
                                        ? 'Anda sekarang mengikuti @user_$userId'
                                        : 'Berhenti mengikuti @user_$userId',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFF16181C),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: isFollowing ? Colors.transparent : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isFollowing ? const Color(0xFF536471) : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                isFollowing ? 'Mengikuti' : 'Ikuti',
                                style: TextStyle(
                                  color: isFollowing ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Judul Pengumuman
                      Text(
                        widget.post.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Isi Postingan
                      Text(
                        widget.post.body,
                        style: const TextStyle(
                          color: Color(0xFFE7E9EA),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tanggal & Info Tayangan
                      Row(
                        children: [
                          const Text(
                            '06.30 · 6 Nov 2026',
                            style: TextStyle(color: xSubText, fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          const Text('·', style: TextStyle(color: xSubText)),
                          const SizedBox(width: 6),
                          Text(
                            '${(widget.post.id ?? 1) * 240} Tayangan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: xBorder, height: 1),
                      const SizedBox(height: 10),

                      // Statistik Interaksi Tersinkronisasi
                      Row(
                        children: [
                          Text(
                            '$repostCount',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          const Text('Repost', style: TextStyle(color: xSubText, fontSize: 14)),
                          const SizedBox(width: 16),
                          Text(
                            '$likeCount',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          const Text('Suka', style: TextStyle(color: xSubText, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: xBorder, height: 1),

                      // Baris Aksi Interaksi Fungsional
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              color: xSubText,
                              onPressed: () {},
                              tooltip: 'Balas',
                            ),
                            IconButton(
                              icon: const Icon(Icons.repeat),
                              color: isReposted ? const Color(0xFF00BA7C) : xSubText,
                              onPressed: () {
                                final willRepost = provider.toggleRepost(postId);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      willRepost
                                          ? 'Postingan berhasil diposting ulang'
                                          : 'Batal memposting ulang',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: const Color(0xFF16181C),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              tooltip: 'Repost',
                            ),
                            IconButton(
                              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                              color: isLiked ? const Color(0xFFF91880) : xSubText,
                              onPressed: () => provider.toggleLike(postId),
                              tooltip: 'Suka',
                            ),
                            IconButton(
                              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                              color: isSaved ? xBlue : xSubText,
                              onPressed: () {
                                final willSave = provider.toggleSaved(postId);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      willSave ? 'Postingan disimpan ke Markah' : 'Dihapus dari Markah',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: const Color(0xFF16181C),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              tooltip: 'Markah',
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_outlined),
                              color: xSubText,
                              onPressed: _sharePost,
                              tooltip: 'Bagikan',
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: xBorder, height: 1),
                    ],
                  ),
                ),

                // Bagian Balasan
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Balasan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // FutureBuilder Komentar
                FutureBuilder<List<Comment>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(28.0),
                          child: CircularProgressIndicator(color: xBlue),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                'Gagal memuat balasan: ${snapshot.error}',
                                style: const TextStyle(color: xSubText, fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _loadComments();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text('Belum ada balasan.', style: TextStyle(color: xSubText)),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: xBorder,
                      ),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 17,
                                backgroundColor: const Color(0xFF2F3336),
                                child: Text(
                                  comment.name.isNotEmpty ? comment.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            comment.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            '@${comment.email.split('@').first}',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: xSubText, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.body,
                                      style: const TextStyle(
                                        color: Color(0xFFE7E9EA),
                                        fontSize: 14,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
