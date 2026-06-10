import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/order_provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/models/order_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (authProvider.user != null) {
      try {
        await orderProvider.loadOrders(authProvider.user!.id);
      } catch (e) {
        debugPrint('Lỗi tải đơn hàng: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0C1B),
        appBar: _buildAppBar(),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text(
                'Vui lòng đăng nhập để xem đơn hàng',
                style: TextStyle(fontSize: 16, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      appBar: _buildAppBar(),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            );
          }

          if (orderProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${orderProvider.errorMessage}',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                    onPressed: _loadOrders,
                    child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (orderProvider.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('Chưa có đơn hàng nào', style: TextStyle(fontSize: 18, color: Colors.white54)),
                  SizedBox(height: 8),
                  Text('Hãy mua sắm để xem đơn hàng tại đây', style: TextStyle(color: Colors.white38)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            color: Colors.purpleAccent,
            backgroundColor: const Color(0xFF1E1A3A),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                return _buildOrderCard(context, order);
              },
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Đơn hàng của tôi',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF16122C),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: order.status.color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: order.status.color.withOpacity(0.3)),
            ),
            child: Icon(_getStatusIcon(order.status), color: order.status.color, size: 22),
          ),
          title: Text(
            'Đơn hàng #${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: order.status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: order.status.color.withOpacity(0.3)),
                ),
                child: Text(
                  order.status.displayName,
                  style: TextStyle(color: order.status.color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${order.totalAmount.toStringAsFixed(0)} ₫',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ],
          ),
          trailing: Text(
            _formatDate(order.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.white38),
          ),
          iconColor: Colors.white38,
          collapsedIconColor: Colors.white38,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF16122C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sản phẩm',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => _buildOrderItem(item)),
                  Divider(color: Colors.white.withOpacity(0.08), height: 24),
                  const Text('Chi tiết đơn hàng',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 8),
                  _buildDetailRow('Ngày đặt hàng', _formatDate(order.createdAt)),
                  _buildDetailRow('Thanh toán', order.paymentMethod),
                  _buildDetailRow('Địa chỉ', order.address),
                  if (order.fullName.isNotEmpty) _buildDetailRow('Họ và tên', order.fullName),
                  if (order.phone.isNotEmpty) _buildDetailRow('Số điện thoại', order.phone),
                  if (order.pointsUsed > 0) _buildDetailRow('Điểm đã dùng', '${order.pointsUsed}'),
                  if (order.pointsEarned > 0) _buildDetailRow('Điểm tích lũy', '${order.pointsEarned}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : 'https://via.placeholder.com/50',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 50,
                height: 50,
                color: const Color(0xFF1E1A3A),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purpleAccent)),
              ),
              errorWidget: (context, url, error) => Container(
                width: 50,
                height: 50,
                color: const Color(0xFF1E1A3A),
                child: const Icon(Icons.image_not_supported, size: 24, color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('Số lượng: ${item.quantity}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${(item.price * item.quantity).toStringAsFixed(0)} ₫',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:     return Icons.pending_outlined;
      case OrderStatus.confirmed:   return Icons.check_circle_outline;
      case OrderStatus.processing:  return Icons.build_outlined;
      case OrderStatus.shipped:     return Icons.local_shipping_outlined;
      case OrderStatus.delivered:   return Icons.done_all;
      case OrderStatus.paid:        return Icons.payment_outlined;
      case OrderStatus.cancelled:   return Icons.cancel_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
