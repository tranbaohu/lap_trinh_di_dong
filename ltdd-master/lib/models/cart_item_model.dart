class CartItem {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    print('CartItem.fromMap: $map');
    return CartItem(
      productId: map['productId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown',
      imageUrl: map['imageUrl']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 1,
    );
  }
}