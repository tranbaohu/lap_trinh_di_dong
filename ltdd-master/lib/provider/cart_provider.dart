import 'package:flutter/material.dart';
import 'package:doan_lttdd/models/cart_item_model.dart';
import 'package:doan_lttdd/database/database_helper.dart';

class CartProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  // Load giỏ hàng
  Future<void> loadCart(String userId) async {
    _userId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
     print('Loading cart for user: $userId (Web mode)');
      
      // Nếu chưa có dữ liệu thì giữ nguyên danh sách hiện tại
      if (_items.isEmpty) {
        print('Cart is empty');
      } else {
        print('Cart has ${_items.length} items');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm vào giỏ hàng (tối ưu)
 Future<void> addToCart({
    required String userId,
    required String productId,
    required String name,
    required String imageUrl,
    required double price,
    int quantity = 1,           // Mặc định là 1
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Tìm xem sản phẩm đã có trong giỏ chưa
      final existingIndex = _items.indexWhere((item) => item.productId == productId);

      if (existingIndex != -1) {
        // Tăng số lượng
        _items[existingIndex].quantity += quantity;
        print('Increased quantity for $name');
      } else {
        // Thêm mới
        _items.add(CartItem(
          productId: productId,
          name: name,
          imageUrl: imageUrl,
          price: price,
          quantity: quantity,
        ));
        print('Added new item: $name');
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('Error adding to cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tăng số lượng
  Future<void> increaseQuantity(String productId) async {
    if (_userId == null) return;
    try {
      await _dbHelper.increaseQuantity(_userId!, productId);
      await loadCart(_userId!);
    } catch (e) {
      print('Error increasing quantity: $e');
    }
  }

  // Giảm số lượng
  Future<void> decreaseQuantity(String productId) async {
    if (_userId == null) return;
    try {
      await _dbHelper.decreaseQuantity(_userId!, productId);
      await loadCart(_userId!);
    } catch (e) {
      print('Error decreasing quantity: $e');
    }
  }

  // Xóa sản phẩm
  Future<void> removeFromCart(String productId) async {
    if (_userId == null) return;
    try {
      await _dbHelper.removeFromCart(_userId!, productId);
      await loadCart(_userId!);
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    if (_userId == null) return;
    try {
      await _dbHelper.clearCart(_userId!);
      _items.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}