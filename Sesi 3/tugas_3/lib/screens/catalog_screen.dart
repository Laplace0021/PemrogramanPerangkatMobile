import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import 'cart_screen.dart';

const List<Book> _books = [
  Book(id: 1, title: 'Laskar Pelangi', author: 'Andrea Hirata', price: 85000),
  Book(id: 2, title: 'Bumi', author: 'Tere Liye', price: 95000),
  Book(id: 3, title: 'Cantik Itu Luka', author: 'Eka Kurniawan', price: 110000),
  Book(id: 4, title: 'Filosofi Teras', author: 'Henry Manampiring', price: 98000),
  Book(id: 5, title: 'Negeri 5 Menara', author: 'Ahmad Fuadi', price: 79000),
];

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NusaBookstore'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Mode terang' : 'Mode gelap',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return IconButton(
                tooltip: 'Keranjang',
                icon: Badge(
                  isLabelVisible: cart.totalItems > 0,
                  label: Text('${cart.totalItems}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _books.length,
        itemBuilder: (context, index) => _BookCard(book: _books[index]),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                _BookCover(book: book),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatRupiah(book.price),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('Tambah ke Keranjang'),
                onPressed: () {
                  context.read<CartProvider>().addItem(book);

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('${book.title} ditambahkan ke keranjang'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sampul buku: gambar dari imageUrl, atau ikon placeholder.
class _BookCover extends StatelessWidget {
  const _BookCover({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final placeholder = Container(
      color: cs.primaryContainer,
      child: Icon(Icons.menu_book_rounded, size: 36, color: cs.onPrimaryContainer),
    );

    final url = book.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 70,
        height: 96,
        child: (url == null || url.isEmpty)
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}
