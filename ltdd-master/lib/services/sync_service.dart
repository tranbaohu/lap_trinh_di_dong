import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doan_lttdd/database/database_helper.dart';
import 'package:doan_lttdd/services/api_service.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ApiService _apiService = ApiService();
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Đồng bộ sản phẩm từ FakeStore API
  Future<void> syncProducts() async {
    if (!await isConnected()) {
      print('No internet connection');
      return;
    }

    try {
      print('Syncing products from FakeStore API...');
      final products = await _apiService.fetchProducts();

      for (var product in products) {
        await _dbHelper.insert('products', {
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
          'brand': product.brand,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }

      print('✅ Synced ${products.length} products');
    } catch (e) {
      print('❌ Sync failed: $e');
    }
  }

  Future<void> syncCart(String userId) async {
    print('Cart sync for user: $userId (not implemented)');
  }

  Future<void> syncWishlist(String userId) async {
    print('Wishlist sync for user: $userId (not implemented)');
  }
}