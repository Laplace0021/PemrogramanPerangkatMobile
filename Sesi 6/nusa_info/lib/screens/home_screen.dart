import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import 'detail_screen.dart';
import 'add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 6. Panggil pemuatan data di initState(), bukan di dalam build()
    Future.microtask(() {
      if (mounted) {
        context.read<PostProvider>().fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _sharePost(Post post) {
    final postUrl = 'https://nusainfo.com/posts/${post.id}';
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

  // 8. Tampilkan SnackBar setelah pengumuman berhasil dibuat via await Navigator.push
  Future<void> _navigateToAddPost() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const AddPostScreen()),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF1D9BF0), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pengumuman "$result" berhasil ditambahkan!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16181C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF2F3336)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const xBlue = Color(0xFF1D9BF0);
    const xBorder = Color(0xFF2F3336);
    const xSubText = Color(0xFF71767B);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: xBlue,
                indicatorWeight: 3.5,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: xSubText,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: const [
                  Tab(text: 'Untuk Anda'),
                  Tab(text: 'Mengikuti'),
                ],
              ),
              const Divider(height: 1, thickness: 1, color: xBorder),
            ],
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF2F3336),
            child: Text(
              'N',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[200]),
            ),
          ),
        ),
        title: const Text(
          'Nusa Info',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Segarkan',
            onPressed: () => context.read<PostProvider>().fetchPosts(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // 7. RefreshIndicator dengan Provider
      body: RefreshIndicator(
        color: xBlue,
        backgroundColor: const Color(0xFF16181C),
        onRefresh: () => context.read<PostProvider>().fetchPosts(),
        child: Consumer<PostProvider>(
          builder: (context, provider, child) {
            // Loading State
            if (provider.isLoading && provider.posts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: xBlue),
              );
            }

            // Error State
            if (provider.errorMessage != null && provider.posts.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Gagal memuat pengumuman',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: xSubText, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.fetchPosts(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Coba Lagi', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }

            final posts = provider.posts;
            if (posts.isEmpty) {
              return const Center(
                child: Text('Belum ada postingan.', style: TextStyle(color: xSubText)),
              );
            }

            // Feed Postingan (ListView.builder)
            return ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.8,
                color: xBorder,
              ),
              itemBuilder: (context, index) {
                final post = posts[index];
                final postId = post.id ?? index;
                final isLiked = provider.isLiked(postId);
                final isReposted = provider.isReposted(postId);
                final isSaved = provider.isSaved(postId);

                final currentLikes = provider.getLikeCount(post);
                final currentReposts = provider.getRepostCount(post);

                final avatarColors = [
                  const Color(0xFF1D9BF0),
                  const Color(0xFF00BA7C),
                  const Color(0xFFF91880),
                  const Color(0xFFFF7A00),
                  const Color(0xFF7856FF),
                ];
                final avatarColor = avatarColors[post.userId % avatarColors.length];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(post: post),
                      ),
                    );
                  },
                  splashColor: Colors.white10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Pengguna
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: avatarColor.withValues(alpha: 0.25),
                          child: Text(
                            'U${post.userId}',
                            style: TextStyle(
                              color: avatarColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Konten Post
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Baris Nama, Badge Verified, Handle, dan ID
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Kontributor ${post.userId}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 15, color: xBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    '@user_${post.userId} · #${post.id}',
                                    style: const TextStyle(color: xSubText, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Judul Post (Bold)
                              Text(
                                post.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Isi Body Post
                              Text(
                                post.body,
                                style: const TextStyle(
                                  color: Color(0xFFE7E9EA),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Baris Aksi Interaksi Terhubung ke Provider
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Komentar
                                  _actionItem(
                                    icon: Icons.chat_bubble_outline,
                                    label: '${(post.id ?? 1) * 3}',
                                    color: xSubText,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(post: post),
                                        ),
                                      );
                                    },
                                  ),

                                  // Repost
                                  _actionItem(
                                    icon: Icons.repeat,
                                    label: '$currentReposts',
                                    color: isReposted ? const Color(0xFF00BA7C) : xSubText,
                                    onTap: () {
                                      final willRepost = provider.toggleRepost(postId);
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            willRepost
                                                ? 'Berhasil memposting ulang ke profil Anda'
                                                : 'Batal memposting ulang',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: const Color(0xFF16181C),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),

                                  // Love
                                  _actionItem(
                                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                                    label: '$currentLikes',
                                    color: isLiked ? const Color(0xFFF91880) : xSubText,
                                    onTap: () => provider.toggleLike(postId),
                                  ),

                                  // Saved (Bookmark)
                                  _actionItem(
                                    icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                                    label: '',
                                    color: isSaved ? xBlue : xSubText,
                                    onTap: () {
                                      final willSave = provider.toggleSaved(postId);
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            willSave ? 'Disimpan ke Markah tersimpan' : 'Dihapus dari Markah',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: const Color(0xFF16181C),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),

                                  // Share
                                  _actionItem(
                                    icon: Icons.share_outlined,
                                    label: '',
                                    color: xSubText,
                                    onTap: () => _sharePost(post),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        backgroundColor: xBlue,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _actionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
