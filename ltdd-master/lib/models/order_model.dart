import 'package:flutter/material.dart';

class Order {
  final String id;
  final String userId;
  final double totalAmount;
  OrderStatus status;
  final String address;
  final String paymentMethod;
  final DateTime createdAt;
  final int pointsUsed;
  final int pointsEarned;
  List<OrderItem> items;
  final String fullName;
  final String phone;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
    this.pointsUsed = 0,
    this.pointsEarned = 0,
    this.items = const [],
    this.fullName = '',
    this.phone = '',
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl = '',
  });
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  paid,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.paid:
        return 'Paid'; // Đã xóa dòng return Colors.amber bị thừa ở đây
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.cyan;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.paid:
        return Colors.amber; // Đã xóa dòng return 'Paid' bị thừa ở đây
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}