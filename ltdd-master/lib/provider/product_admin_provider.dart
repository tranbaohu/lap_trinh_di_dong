import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doan_lttdd/database/database_helper.dart';
import 'package:doan_lttdd/models/product_model.dart';

class ProductAdminProvider with ChangeNotifier {
  /// Refresh the product list from the data source.
  /// Useful for non‑admin widgets that need the latest data after
  /// an admin operation.
  Future<void> refreshProducts() async => await fetchProducts();
  static const String _webProductsKey = 'table_products';
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  Product? _selectedProduct;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Product? get selectedProduct => _selectedProduct;

  ProductAdminProvider() {
    _init();
  }

  Future<void> _init() async {
    await fetchProducts();
  }

  List<Product> _defaultProducts() {
    return [
      Product(
        id: 'p1',
        name: 'iPhone 15 Pro',
        description: 'Điện thoại Apple iPhone 15 Pro, hiệu năng mạnh mẽ.',
        price: 25990000.0,
        discountPrice: 23990000.0,
        category: 'Electronics',
        images: ['https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600'],
        stock: 20,
        rating: 4.8,
        soldCount: 120,
        brand: 'Apple',
      ),
      Product(
        id: 'p2',
        name: 'Samsung Galaxy S24',
        description: 'Điện thoại Samsung Galaxy S24 màn hình đẹp, pin tốt.',
        price: 21990000.0,
        discountPrice: 19990000.0,
        category: 'Electronics',
        images: ['https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=600'],
        stock: 30,
        rating: 4.7,
        soldCount: 98,
        brand: 'Samsung',
      ),
      Product(
        id: 'p3',
        name: 'Áo thun nam basic',
        description: 'Áo thun cotton form rộng, dễ phối đồ.',
        price: 199000.0,
        discountPrice: 149000.0,
        category: 'Fashion',
        images: ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600'],
        stock: 100,
        rating: 4.5,
        soldCount: 320,
        brand: 'Local Brand',
      ),
    ];
  }

  Map<String, dynamic> _productToStoredMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'discountPrice': product.discountPrice,
      'category': product.category,
      'images': product.images.join(','),
      'stock': product.stock,
      'rating': product.rating,
      'soldCount': product.soldCount,
      'brand': product.brand ?? '',
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> _loadWebProductMaps() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProducts = prefs.getStringList(_webProductsKey) ?? [];

    if (rawProducts.isEmpty) {
      final seededProducts = _defaultProducts().map(_productToStoredMap).toList();
      await _saveWebProductMaps(seededProducts);
      return seededProducts;
    }

    return rawProducts
        .map((raw) => Map<String, dynamic>.from(json.decode(raw)))
        .toList();
  }

  Future<void> _saveWebProductMaps(List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _webProductsKey,
      products.map((product) => json.encode(product)).toList(),
    );
  }

  List<String> _normalizeImages(String imageUrl) {
    return imageUrl
        .split(',')
        .map((image) => image.trim())
        .where((image) => image.isNotEmpty)
        .toList();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final productData = kIsWeb
          ? await _loadWebProductMaps()
          : await _dbHelper.query('products', orderBy: 'lastUpdated DESC');

      _products = productData.map((data) => Product.fromJson(data)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch products: $e';
      print('Fetch products error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required String category,
    required String brand,
    required int stock,
    required String imageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (name.trim().isEmpty || description.trim().isEmpty || category.trim().isEmpty) {
        _errorMessage = 'Name, description and category are required';
        return false;
      }
      if (price <= 0) {
        _errorMessage = 'Price must be greater than 0';
        return false;
      }
      if (discountPrice != null && (discountPrice <= 0 || discountPrice >= price)) {
        _errorMessage = 'Discount price must be less than price';
        return false;
      }
      if (stock < 0) {
        _errorMessage = 'Stock cannot be negative';
        return false;
      }

      final newProduct = Product(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        description: description.trim(),
        price: price,
        discountPrice: discountPrice,
        category: category.trim(),
        brand: brand.trim(),
        stock: stock,
        images: _normalizeImages(imageUrl),
        rating: 0,
        soldCount: 0,
      );
      final productMap = _productToStoredMap(newProduct);

      if (kIsWeb) {
        final products = await _loadWebProductMaps();
        products.add(productMap);
        await _saveWebProductMaps(products);
      } else {
        await _dbHelper.insert('products', productMap);
      }

      _products.insert(0, newProduct);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      print('Add product error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required String category,
    required String brand,
    required int stock,
    required String imageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _products.indexWhere((product) => product.id == productId);
      if (index == -1) {
        _errorMessage = 'Product not found';
        return false;
      }
      if (name.trim().isEmpty || description.trim().isEmpty || category.trim().isEmpty) {
        _errorMessage = 'Name, description and category are required';
        return false;
      }
      if (price <= 0) {
        _errorMessage = 'Price must be greater than 0';
        return false;
      }
      if (discountPrice != null && (discountPrice <= 0 || discountPrice >= price)) {
        _errorMessage = 'Discount price must be less than price';
        return false;
      }
      if (stock < 0) {
        _errorMessage = 'Stock cannot be negative';
        return false;
      }

      final current = _products[index];
      final images = _normalizeImages(imageUrl);
      final updatedProduct = Product(
        id: current.id,
        name: name.trim(),
        description: description.trim(),
        price: price,
        discountPrice: discountPrice,
        category: category.trim(),
        images: images.isEmpty ? current.images : images,
        stock: stock,
        rating: current.rating,
        soldCount: current.soldCount,
        brand: brand.trim(),
      );
      final productMap = _productToStoredMap(updatedProduct);

      if (kIsWeb) {
        final products = await _loadWebProductMaps();
        final storedIndex = products.indexWhere((product) => product['id']?.toString() == productId);
        if (storedIndex == -1) {
          _errorMessage = 'Product not found';
          return false;
        }
        products[storedIndex] = productMap;
        await _saveWebProductMaps(products);
      } else {
        final updatedCount = await _dbHelper.update(
          'products',
          productMap,
          where: 'id = ?',
          whereArgs: [productId],
        );
        if (updatedCount == 0) {
          _errorMessage = 'Product not found';
          return false;
        }
      }

      _products[index] = updatedProduct;
      _selectedProduct = updatedProduct;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      print('Update product error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _products.indexWhere((product) => product.id == productId);
      if (index == -1) {
        _errorMessage = 'Product not found';
        return false;
      }

      if (kIsWeb) {
        final products = await _loadWebProductMaps();
        final beforeLength = products.length;
        products.removeWhere((product) => product['id']?.toString() == productId);
        if (products.length == beforeLength) {
          _errorMessage = 'Product not found';
          return false;
        }
        await _saveWebProductMaps(products);
      } else {
        final deletedCount = await _dbHelper.delete(
          'products',
          where: 'id = ?',
          whereArgs: [productId],
        );
        if (deletedCount == 0) {
          _errorMessage = 'Product not found';
          return false;
        }
      }

      _products.removeAt(index);
      if (_selectedProduct?.id == productId) {
        _selectedProduct = null;
      }
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      print('Delete product error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
