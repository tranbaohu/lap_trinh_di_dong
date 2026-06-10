import 'package:flutter/material.dart';
import 'package:doan_lttdd/models/product_model.dart';
import 'package:doan_lttdd/services/api_service.dart';
import 'package:doan_lttdd/database/database_helper.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Product> _products = [];
  List<Product> _recommendedProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get recommendedProducts => _recommendedProducts;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Lấy sản phẩm từ API
      _products = await _apiService.fetchProducts();

      // Lưu vào database local
      for (var product in _products) {
        await _dbHelper.insert('products', product.toJson());
      }

      // Lấy danh sách danh mục
      _categories = await _apiService.fetchCategories();
      _categories.insert(0, 'All');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecommendedProducts(String userId) async {
    try {
      _recommendedProducts = await _apiService.getRecommendedProducts(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading recommendations: $e');
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}