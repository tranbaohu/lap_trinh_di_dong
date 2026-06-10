import 'package:flutter/material.dart';
import 'package:doan_lttdd/models/order_model.dart';
import 'package:doan_lttdd/database/database_helper.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders(String userId) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lấy orders từ database
      final ordersData = await _dbHelper.query(
        'orders',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );

      _orders = [];

      for (var orderData in ordersData) {
        // Lấy order items
        final itemsData = await _dbHelper.query(
          'order_items',
          where: 'orderId = ?',
          whereArgs: [orderData['id']],
        );

        final items = itemsData.map((item) => OrderItem(
          productId: item['productId'],
          productName: item['productName'],
          quantity: item['quantity'],
          price: (item['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: item['imageUrl'] ?? '',
        )).toList();

        // Parse status
        OrderStatus status;
        switch (orderData['status']) {
          case 'pending':
            status = OrderStatus.pending;
            break;
          case 'confirmed':
            status = OrderStatus.confirmed;
            break;
          case 'processing':
            status = OrderStatus.processing;
            break;
          case 'shipped':
            status = OrderStatus.shipped;
            break;
          case 'delivered':
            status = OrderStatus.delivered;
            break;
          case 'cancelled':
            status = OrderStatus.cancelled;
            break;
          default:
            status = OrderStatus.pending;
        }

        _orders.add(Order(
          id: orderData['id'],
          userId: orderData['userId'],
          totalAmount: (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0,
          status: status,
          address: orderData['address'] ?? '',
          paymentMethod: orderData['paymentMethod'] ?? 'COD',
          createdAt: DateTime.parse(orderData['createdAt']),
          pointsUsed: orderData['pointsUsed'] ?? 0,
          pointsEarned: orderData['pointsEarned'] ?? 0,
          items: items,
          fullName: orderData['fullName'] ?? '',
          phone: orderData['phone'] ?? '',
        ));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error loading orders: $e');
    }
  }

  // lib/provider/order_provider.dart
  Future<void> createOrder(Order order) async {
    try {
      // Lưu vào database
      await _dbHelper.insert('orders', {
        'id': order.id,
        'userId': order.userId,
        'totalAmount': order.totalAmount,
        'status': 'pending',
        'address': order.address,
        'paymentMethod': order.paymentMethod,
        'createdAt': order.createdAt.toIso8601String(),
        'pointsUsed': order.pointsUsed,
        'pointsEarned': order.pointsEarned,
        'fullName': order.fullName,
        'phone': order.phone,
      });

      // Lưu order items
      for (var item in order.items) {
        await _dbHelper.insert('order_items', {
          'orderId': order.id,
          'productId': item.productId,
          'productName': item.productName,
          'quantity': item.quantity,
          'price': item.price,
          'imageUrl': item.imageUrl,
        });
      }

      print('Order created successfully: ${order.id}');
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Failed to create order');
    }
  }

  // Thêm order mới vào provider (không cần reload toàn bộ)
  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
