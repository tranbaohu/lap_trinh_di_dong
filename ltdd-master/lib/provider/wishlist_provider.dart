import 'package:flutter/material.dart';
import 'package:doan_lttdd/models/product_model.dart';
import 'package:doan_lttdd/database/database_helper.dart';
import 'package:doan_lttdd/services/sync_service.dart';

class WishlistProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SyncService _syncService = SyncService();

  List<Product> _items = [];
  String? _userId;

  List<Product> get items => _items;
  int get itemCount => _items.length;

  Future<void> loadWishlist(String userId) async {
    _userId = userId;
    final wishlistData = await _dbHelper.query(
      'wishlist',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    _items = [];
    for (var data in wishlistData) {
      final product = await _getProductById(data['productId']);
      if (product != null) {
        _items.add(product);
      }
    }
    notifyListeners();

    await _syncService.syncWishlist(userId);
  }

  Future<Product?> _getProductById(String id) async {
    final productData = await _dbHelper.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (productData.isNotEmpty) {
      return Product.fromJson(productData.first);
    }
    return null;
  }

  Future<void> addToWishlist(Product product) async {
    if (!_items.any((item) => item.id == product.id)) {
      _items.add(product);

      await _dbHelper.insert('wishlist', {
        'productId': product.id,
        'userId': _userId,
      });

      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    _items.removeWhere((item) => item.id == productId);

    await _dbHelper.delete(
      'wishlist',
      where: 'productId = ? AND userId = ?',
      whereArgs: [productId, _userId],
    );

    notifyListeners();
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }
}