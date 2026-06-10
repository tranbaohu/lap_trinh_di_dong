import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan_lttdd/models/product_model.dart';
import 'package:doan_lttdd/utils/constants.dart';

class ApiService {
  final String baseUrl = Constants.apiBaseUrl;

  // Lấy danh sách sản phẩm
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product(
          id: item['id'].toString(),
          name: item['title'] ?? '',
          description: item['description'] ?? '',
          price: (item['price'] as num).toDouble(),
          discountPrice: null,
          category: item['category'] ?? 'General',
          images: [item['image'] ?? 'https://picsum.photos/400/400'],
          stock: 100,
          rating: (item['rating']?['rate'] as num?)?.toDouble() ?? 4.5,
          soldCount: 0,
          brand: 'Unknown',
        )).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Lấy sản phẩm theo ID
  Future<Product> fetchProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product(
          id: data['id'].toString(),
          name: data['title'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num).toDouble(),
          discountPrice: null,
          category: data['category'] ?? 'General',
          images: [data['image'] ?? 'https://picsum.photos/400/400'],
          stock: 100,
          rating: (data['rating']?['rate'] as num?)?.toDouble() ?? 4.5,
          soldCount: 0,
          brand: 'Unknown',
        );
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Lấy danh mục sản phẩm
  Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item.toString()).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Lấy sản phẩm theo danh mục
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product(
          id: item['id'].toString(),
          name: item['title'] ?? '',
          description: item['description'] ?? '',
          price: (item['price'] as num).toDouble(),
          discountPrice: null,
          category: item['category'] ?? category,
          images: [item['image'] ?? 'https://picsum.photos/400/400'],
          stock: 100,
          rating: (item['rating']?['rate'] as num?)?.toDouble() ?? 4.5,
          soldCount: 0,
          brand: 'Unknown',
        )).toList();
      } else {
        throw Exception('Failed to load products by category');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Lấy sản phẩm giới hạn
  Future<List<Product>> fetchProductsWithLimit(int limit) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product(
          id: item['id'].toString(),
          name: item['title'] ?? '',
          description: item['description'] ?? '',
          price: (item['price'] as num).toDouble(),
          discountPrice: null,
          category: item['category'] ?? 'General',
          images: [item['image'] ?? 'https://picsum.photos/400/400'],
          stock: 100,
          rating: (item['rating']?['rate'] as num?)?.toDouble() ?? 4.5,
          soldCount: 0,
          brand: 'Unknown',
        )).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Tìm kiếm sản phẩm
  Future<List<Product>> searchProducts(String query) async {
    try {
      final allProducts = await fetchProducts();
      if (query.isEmpty) return allProducts;
      return allProducts.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  // Gợi ý sản phẩm
  Future<List<Product>> getRecommendedProducts(String userId) async {
    try {
      final allProducts = await fetchProducts();
      allProducts.sort((a, b) => b.rating.compareTo(a.rating));
      return allProducts.take(4).toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== AUTHENTICATION ====================

  // Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': true,
          'token': data['access_token'],
        };
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Lấy thông tin user
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}