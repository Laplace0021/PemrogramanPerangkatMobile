class Book {
  final int id;
  final String title;
  final String author;
  final double price;
  final String? imageUrl;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    this.imageUrl,
  });
}
