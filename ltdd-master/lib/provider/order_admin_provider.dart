import 'package:flutter/material.dart';
import 'package:doan_lttdd/models/order_model.dart';
import 'package:doan_lttdd/database/database_helper.dart';

class OrderAdminProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load tất cả đơn hàng (dùng cho Admin)
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ordersData = await _dbHelper.query(
        'orders',
        orderBy: 'createdAt DESC',
      );

      _orders = [];

      for (var orderData in ordersData) {
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

        _orders.add(Order(
          id: orderData['id'],
          userId: orderData['userId'],
          totalAmount: (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0,
          status: _parseStatus(orderData['status']),
          address: orderData['address'] ?? '',
          paymentMethod: orderData['paymentMethod'] ?? '',
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
      print('Error fetching all orders: $e');
    }
  }

  OrderStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'paid':
        return OrderStatus.paid;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Cập nhật trạng thái đơn hàng (Admin)
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _dbHelper.update(
        'orders',
        {'status': newStatus.name}, // Lưu bằng tên enum dạng chữ (ví dụ: 'paid')
        where: 'id = ?',
        whereArgs: [orderId],
      );

      // Cập nhật trạng thái ngay trong bộ nhớ danh sách cục bộ
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index].status = newStatus;
        // Gọi notifyListeners() cực kỳ quan trọng để Analytics và Dashboard tự động tính lại tiền
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
}