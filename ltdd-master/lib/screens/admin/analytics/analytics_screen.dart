import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/order_admin_provider.dart';
import 'package:doan_lttdd/provider/user_admin_provider.dart';
import 'package:doan_lttdd/models/order_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderAdminProvider>().fetchAllOrders();
        context.read<UserAdminProvider>().fetchUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      appBar: AppBar(
        title: const Text('Thống kê & Phân tích'),
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
      body: Consumer2<OrderAdminProvider, UserAdminProvider>(
        builder: (context, orderProvider, userProvider, _) {
          if (orderProvider.isLoading || userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
          }

          final orders = orderProvider.orders;
          final users = userProvider.users;

          // CHỈ TÍNH DOANH THU TỪ CÁC ĐƠN HÀNG ĐÃ THANH TOÁN (status == OrderStatus.paid)
          final paidOrders = orders.where((o) => o.status == OrderStatus.paid).toList();
          final double totalRevenue = paidOrders.fold(0.0, (sum, item) => sum + item.totalAmount);

          // Đếm số lượng theo các trạng thái khác nhau để trực quan hóa
          final pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;
          final paidCount = paidOrders.length;
          final cancelledCount = orders.where((o) => o.status == OrderStatus.cancelled).length;

          return RefreshIndicator(
            onRefresh: () async {
              await orderProvider.fetchAllOrders();
              await userProvider.fetchUsers();
            },
            color: Colors.purpleAccent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard(
                        'Tổng doanh thu',
                        '\$${totalRevenue.toStringAsFixed(2)}',
                        Icons.monetization_on,
                        Colors.greenAccent,
                      ),
                      _buildStatCard(
                        'Tổng người dùng',
                        '${users.length}',
                        Icons.people,
                        Colors.blueAccent,
                      ),
                      _buildStatCard(
                        'Tổng đơn hàng',
                        '${orders.length}',
                        Icons.shopping_bag,
                        Colors.purpleAccent,
                      ),
                      _buildStatCard(
                        'Đã thanh toán',
                        '$paidCount',
                        Icons.assignment_turned_in,
                        Colors.tealAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Phân bổ trạng thái đơn hàng',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1A3A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Chờ xử lý / Chưa thanh toán', '$pendingCount', Colors.orange),
                        const Divider(color: Colors.white12),
                        _buildDetailRow('Đã thanh toán', '$paidCount', Colors.green),
                        const Divider(color: Colors.white12),
                        _buildDetailRow('Đã hủy', '$cancelledCount', Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1E1A3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}