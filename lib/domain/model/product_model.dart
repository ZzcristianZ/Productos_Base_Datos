import 'package:segundoparcial/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.title,
    required super.description,
    required super.price,
    required super.brand,
    required super.category,
    required super.stock,
    required super.rating,
    required super.isAvailable,
    required super.createdAt,
    required super.tags,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      brand: json['brand']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "price": price,
    "brand": brand,
    "category": category,
    "stock": stock,
    "rating": rating,
    "tags": tags,
  };
}
