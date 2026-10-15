import 'package:flutter/foundation.dart';

import '../models/book.dart';

String formatRupiah(num value) {
  final digits = value.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}Rp $buffer';
}

class CartItem {
  final Book book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});

  double get subtotal => book.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  void addItem(Book book) {
    final existing = _items[book.id];
    if (existing != null) {
      existing.quantity += 1;
    } else {
      _items[book.id] = CartItem(book: book);
    }
    notifyListeners();
  }

  void removeItem(int bookId) {
    final existing = _items[bookId];
    if (existing == null) return;

    if (existing.quantity > 1) {
      existing.quantity -= 1;
    } else {
      _items.remove(bookId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
