import 'dart:convert';

class Product {
  bool isActive;
  final String id;
  String name;
  String description;
  double price;
  double? discountPrice;
  String category;
  List<String> images;
  int stock;
  double rating;
  int soldCount;
  String? brand;

  Product({
    this.isActive = true,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.category,
    required this.images,
    required this.stock,
    this.rating = 0,
    this.soldCount = 0,
    this.brand,
  });

  double get finalPrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'discountPrice': discountPrice,
        'category': category,
        'images': images,
        'stock': stock,
        'rating': rating,
        'soldCount': soldCount,
        'brand': brand,
        'isActive': isActive,
      };

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return double.tryParse(text);
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static List<String> _parseImages(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((image) => image.toString()).where((image) => image.isNotEmpty).toList();
    }

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return [];

    if (text.startsWith('[')) {
      try {
        final decoded = json.decode(text);
        if (decoded is List) {
          return decoded.map((image) => image.toString()).where((image) => image.isNotEmpty).toList();
        }
      } catch (_) {}
    }

    return text
        .split(',')
        .map((image) => image.trim())
        .where((image) => image.isNotEmpty)
        .toList();
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: _toDouble(json['price']),
        discountPrice: _toNullableDouble(json['discountPrice']),
        category: json['category']?.toString() ?? '',
        images: _parseImages(json['images']),
        stock: _toInt(json['stock']),
        rating: _toDouble(json['rating']),
        soldCount: _toInt(json['soldCount']),
        brand: json['brand']?.toString(),
        isActive: json['isActive'] == true || json['isActive'] == 'true',
      );
}
