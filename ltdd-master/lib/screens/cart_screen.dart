import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/cart_provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doan_lttdd/screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (authProvider.user != null) {
      await cartProvider.loadCart(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thừa hưởng quầng sáng neon từ nền tảng bóng đêm sâu thẳm của hệ thống
      backgroundColor: Colors.transparent,

      // --- APP BAR ĐỒNG BỘ HIỆU ỨNG KÍNH MỜ ---
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)], // Gradient Hồng - Tím Cyberpunk
          ).createShader(bounds),
          child: const Text(
            'My Cart',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
              fontSize: 22,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF16122C).withOpacity(0.4), // Glassmorphism làm mờ nền
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              if (cartProvider.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444)),
                  onPressed: () => _showClearCartDialog(context, cartProvider),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),

      // --- PHẦN BODY CHUYỂN ĐỔI THEO TRẠNG THÁI RỰC MÀU ---
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD946EF)),
              ),
            );
          }

          if (cartProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gpp_bad_rounded, size: 64, color: const Color(0xFFEF4444).withOpacity(0.8)),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${cartProvider.errorMessage}',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _loadCart,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          // Giao diện khi giỏ hàng trống (Khắc phục hoàn toàn tình trạng đơn điệu ở hình image_ae6cad.png)
          if (cartProvider.items.isEmpty) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Quầng sáng Neon tỏa mờ phía sau giỏ hàng tạo chiều sâu kĩ thuật số
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B5CF6).withOpacity(0.12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 90,
                        color: const Color(0xFF8B5CF6).withOpacity(0.7),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                          'Giỏ hàng trống',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)
                      ),
                      const SizedBox(height: 6),
                      Text(
                          'Hãy thêm sản phẩm vào giỏ hàng',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Danh sách các thẻ sản phẩm mờ ảo cao cấp
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFD946EF),
                  backgroundColor: const Color(0xFF1E1A3A),
                  onRefresh: _loadCart,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03), // Khối kính mờ cho từng item
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            // Hình ảnh bọc khung viền Neon nhẹ
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 85,
                                height: 85,
                                color: const Color(0xFF1E1A3A),
                                padding: const EdgeInsets.all(4),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: Colors.white10),
                                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image_rounded, color: Colors.white24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Thông tin chi tiết sản phẩm
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.price.toStringAsFixed(0)} ₫',
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white60, fontSize: 13),
                                  ),
                                  const SizedBox(height: 12),

                                  // Bộ điều khiển tăng giảm số lượng phong cách bo tròn Modern Rounded
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.04),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove_rounded,
                                                size: 18,
                                                color: item.quantity > 1 ? Colors.white : Colors.white24,
                                              ),
                                              onPressed: item.quantity > 1 ? () => cartProvider.decreaseQuantity(item.productId) : null,
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFFD946EF)),
                                              onPressed: () => cartProvider.increaseQuantity(item.productId),
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Tổng giá tiền của riêng item đó dạt màu Neon rực rỡ
                                      Text(
                                        '${item.totalPrice.toStringAsFixed(0)} ₫',
                                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD946EF), fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // --- BOTTOM PANEL TÍNH TIỀN VÀ THANH TOÁN ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF120E25).withOpacity(0.85), // Kính mờ đậm bảo vệ đáy màn hình
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng tiền:', style: TextStyle(fontSize: 16, color: Colors.white54, fontWeight: FontWeight.bold)),
                          Text(
                            '${cartProvider.totalPrice.toStringAsFixed(0)} ₫',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD946EF), // Đổi từ xanh lam sang hồng tím Cyberpunk rực lửa
                            disabledBackgroundColor: Colors.white12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: cartProvider.items.isEmpty ? null : () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                          },
                          child: Text(
                            'Thanh toán',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cartProvider.items.isEmpty ? Colors.white30 : Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- HỘP THOẠI XÓA GIỎ HÀNG ĐỒNG BỘ PHONG CÁCH ---
  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1A3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          title: const Text('Xóa giỏ hàng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm khỏi giỏ hàng điện tử?', style: TextStyle(color: Colors.white60)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await cartProvider.clearCart();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã làm sạch giỏ hàng'),
                      backgroundColor: Color(0xFF1E1A3A),
                    ),
                  );
                }
              },
              child: const Text('Xóa tất cả', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}