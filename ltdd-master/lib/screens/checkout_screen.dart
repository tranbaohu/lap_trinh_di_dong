import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/cart_provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/provider/order_provider.dart';
import 'package:doan_lttdd/provider/order_admin_provider.dart';
import 'package:doan_lttdd/screens/orders_screen.dart';
import 'package:doan_lttdd/models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _paymentMethod = 'COD';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _fullNameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final orderAdminProvider = Provider.of<OrderAdminProvider>(context, listen: false);

      if (authProvider.user == null) throw Exception('Vui lòng đăng nhập');

      dynamic dynamicItems = cartProvider.items;
      List<dynamic> rawCartList = [];
      if (dynamicItems is Map) {
        rawCartList = dynamicItems.values.toList();
      } else if (dynamicItems is List) {
        rawCartList = dynamicItems;
      } else {
        throw Exception('Dữ liệu giỏ hàng không hợp lệ.');
      }

      if (rawCartList.isEmpty) throw Exception('Giỏ hàng trống');

      double calculatedTotalAmount = 0.0;
      for (var item in rawCartList) {
        calculatedTotalAmount += (item.price as num).toDouble() * (item.quantity as int);
      }

      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      final List<OrderItem> orderItems = rawCartList.map((item) {
        return OrderItem(
          productId: item.productId.toString(),
          productName: item.name.toString(),
          quantity: item.quantity as int,
          price: (item.price as num).toDouble(),
          imageUrl: item.imageUrl?.toString() ?? '',
        );
      }).toList();

      final order = Order(
        id: orderId,
        userId: authProvider.user!.id,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        totalAmount: calculatedTotalAmount,
        status: OrderStatus.pending,
        paymentMethod: _paymentMethod,
        createdAt: DateTime.now(),
        items: orderItems,
      );

      await orderProvider.createOrder(order);
      await orderAdminProvider.fetchAllOrders();
      cartProvider.clearCart();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Đặt hàng thành công! Vui lòng chờ Admin xác nhận.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt hàng thất bại: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16122C),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Thông tin giao hàng
            _buildSection(
              title: 'Thông tin giao hàng',
              child: Column(
                children: [
                  _buildDarkTextField(
                    controller: _fullNameController,
                    label: 'Họ và tên',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildDarkTextField(
                    controller: _phoneController,
                    label: 'Số điện thoại',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildDarkTextField(
                    controller: _addressController,
                    label: 'Địa chỉ nhận hàng',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Phương thức thanh toán
            _buildSection(
              title: 'Phương thức thanh toán',
              child: Column(
                children: [
                  _buildPaymentRadio('Thanh toán khi nhận hàng (COD)', 'COD', Icons.local_shipping_outlined),
                  _buildPaymentRadio('Thẻ tín dụng', 'Credit Card', Icons.credit_card_outlined),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tóm tắt đơn hàng
            _buildSection(
              title: 'Tóm tắt đơn hàng',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng tiền', style: TextStyle(color: Colors.white70, fontSize: 15)),
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      double total = 0.0;
                      dynamic itemsData = cart.items;
                      List<dynamic> list = [];
                      if (itemsData is Map) {
                        list = itemsData.values.toList();
                      } else if (itemsData is List) {
                        list = itemsData;
                      }
                      for (var element in list) {
                        total += (element.price as num).toDouble() * (element.quantity as int);
                      }
                      return Text(
                        '${total.toStringAsFixed(0)} ₫',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD946EF),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _isProcessing ? null : _placeOrder,
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Đặt hàng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF16122C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }

  Widget _buildPaymentRadio(String title, String value, IconData icon) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.1) : const Color(0xFF16122C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF8B5CF6) : Colors.white38, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
