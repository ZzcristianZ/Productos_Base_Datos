abstract class Product {
  final String title;
  final String description;
  final double price;
  final String brand;
  final String category;
  final int stock;
  final double rating;
  final bool isAvailable;
  final DateTime createdAt;
  final List<String> tags;

  const Product({
    required this.title,
    required this.description,
    required this.price,
    required this.brand,
    required this.category,
    required this.stock,
    required this.rating,
    required this.isAvailable,
    required this.createdAt,
    required this.tags,
  });
}