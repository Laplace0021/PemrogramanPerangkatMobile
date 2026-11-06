import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    // Validasi form dengan GlobalKey
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newPost = Post(
        userId: 1,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );

      // Menambahkan postingan melalui Provider (Global State Management)
      final createdPost = await context.read<PostProvider>().addPost(newPost);

      if (!mounted) return;

      // Kembali ke layar sebelumnya membawa judul postingan untuk SnackBar
      Navigator.pop(context, createdPost.title);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim postingan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        backgroundColor: Colors.black,
        leading: TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        leadingWidth: 70,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: xBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: xBlue.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Posting',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Pengguna
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF2F3336),
                      child: Text(
                        'N',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Input Judul dan Isi Postingan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge Audience ("Semua Orang")
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: xBlue),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Semua Orang',
                                  style: TextStyle(
                                    color: xBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, color: xBlue, size: 18),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Form Judul
                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Judul pengumuman...',
                              hintStyle: TextStyle(
                                color: xSubText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Judul tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: xBorder, height: 1),
                          const SizedBox(height: 12),

                          // Form Isi Postingan
                          TextFormField(
                            controller: _bodyController,
                            maxLines: 8,
                            minLines: 4,
                            style: const TextStyle(
                              color: Color(0xFFE7E9EA),
                              fontSize: 16,
                              height: 1.4,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Sedang terjadi apa?!',
                              hintStyle: TextStyle(
                                color: xSubText,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Isi pengumuman tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Toolbar khas Compose Tweet X
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: xBorder, width: 0.8)),
            ),
            child: Row(
              children: [
                _toolIcon(Icons.image_outlined),
                const SizedBox(width: 18),
                _toolIcon(Icons.gif_box_outlined),
                const SizedBox(width: 18),
                _toolIcon(Icons.ballot_outlined),
                const SizedBox(width: 18),
                _toolIcon(Icons.location_on_outlined),
                const Spacer(),
                const Text(
                  'Siapa saja bisa membalas',
                  style: TextStyle(color: xBlue, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolIcon(IconData icon) {
    return Icon(icon, color: const Color(0xFF1D9BF0), size: 22);
  }
}
