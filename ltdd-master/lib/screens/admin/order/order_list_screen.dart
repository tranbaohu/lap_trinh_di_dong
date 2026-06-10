import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/order_admin_provider.dart';
import 'package:doan_lttdd/models/order_model.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({Key? key}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderAdminProvider>().fetchAllOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.purpleAccent,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.purpleAccent),
      ),
      body: Consumer<OrderAdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
          }

          if (provider.orders.isEmpty) {
            return const Center(
              child: Text('Chưa có đơn hàng nào.', style: TextStyle(color: Colors.white70)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAllOrders(),
            color: Colors.purpleAccent,
            child: ListView.builder(
              itemCount: provider.orders.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return Card(
                  color: const Color(0xFF1E1A3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mã đơn: ${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}...',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: order.status.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: order.status.color.withOpacity(0.5)),
                              ),
                              child: Text(
                                order.status.displayName,
                                style: TextStyle(color: order.status.color, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        Text('Khách hàng: ${order.fullName}', style: const TextStyle(color: Colors.white70)),
                        Text('Điện thoại: ${order.phone}', style: const TextStyle(color: Colors.white70)),
                        Text('Tổng: ${order.totalAmount.toStringAsFixed(0)} ₫', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),

                        // Khu vực các nút bấm hành động cập nhật trạng thái của Admin
                        const Text('Cập nhật trạng thái:', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: OrderStatus.values.map((status) {
                              final isCurrentStatus = order.status == status;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: OutlinedButton(
                                  onPressed: isCurrentStatus
                                      ? null
                                      : () async {
                                    final success = await provider.updateOrderStatus(order.id, status);
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(status == OrderStatus.paid
                                              ? '💸 Đơn hàng đã được đánh dấu THANH TOÁN! Khách hàng đã được thông báo.'
                                              : 'Đã cập nhật: ${status.displayName}'),
                                          backgroundColor: status == OrderStatus.paid ? Colors.green : Colors.purple,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: isCurrentStatus ? Colors.grey : status.color),
                                    backgroundColor: isCurrentStatus ? Colors.white10 : Colors.transparent,
                                  ),
                                  child: Text(
                                    status.displayName,
                                    style: TextStyle(color: isCurrentStatus ? Colors.grey : status.color),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}