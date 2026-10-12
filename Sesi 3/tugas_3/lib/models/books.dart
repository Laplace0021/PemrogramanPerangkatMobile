class BookModel {
  final int id;
  final String title;
  final String author;
  final double price;
  final String category;
  final String? imgUrl;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.category,
    this.imgUrl,
  });
}