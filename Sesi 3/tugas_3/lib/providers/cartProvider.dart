import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/cartItems.dart';
import '../models/books.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItems> _items = {};

  Map<String, CartItems> get items => Map.unmodifiable(_items);

  int get totalItems{
    return _items.values.fold(0,(sum,item)=> sum+item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(BookModel book) {
    final bookId = book.id.toString();
    if (_items.containsKey(bookId)){
      _items[bookId]!.quantity += 1;
    } else {
      _items[bookId] = CartItems(book: book, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(String BookId){
    if (!_items.containsKey(BookId)) return;
    if (_items[BookId]!.quantity>1){
      _items[BookId]!.quantity -=1;
    } else {
      items.remove(BookId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}