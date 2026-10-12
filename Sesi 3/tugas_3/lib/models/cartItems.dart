import 'books.dart';

class CartItems {
  final BookModel book;
  int quantity;

  CartItems({
    required this.book, 
    this.quantity =1,
    });
    double get totalPrice => (book.price * quantity);
} 