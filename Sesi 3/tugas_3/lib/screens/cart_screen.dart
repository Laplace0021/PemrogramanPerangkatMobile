import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _checkout(BuildContext context) {
    context.read<CartProvider>().clearCart();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil! Keranjang telah dikosongkan.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? const _EmptyCart()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _CartItemCard(item: items[index]),
                  ),
          ),
          _SummaryCard(
            totalItems: cart.totalItems,
            totalPrice: cart.totalPrice,
            onCheckout: items.isEmpty ? null : () => _checkout(context),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove_shopping_cart_outlined,
            size: 80,
            color: cs.onSurfaceVariant.withAlpha(120),
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang Anda masih kosong',
            style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final book = item.book;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.menu_book_rounded, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatRupiah(book.price),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: ${formatRupiah(item.subtotal)}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary),
                  ),
                ],
              ),
            ),
            // Tombol  -  jumlah  +
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Kurangi',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => context.read<CartProvider>().removeItem(book.id),
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: 'Tambah',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => context.read<CartProvider>().addItem(book),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalItems,
    required this.totalPrice,
    required this.onCheckout,
  });

  final int totalItems;
  final double totalPrice;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Item', style: TextStyle(color: cs.onSurfaceVariant)),
                  Text('$totalItems buku', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatRupiah(totalPrice),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: onCheckout,
                  child: const Text(
                    'Checkout / Bayar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
