import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/wishlist_provider.dart';
import 'package:doan_lttdd/provider/cart_provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/widgets/product_card.dart';
import 'package:doan_lttdd/screens/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      appBar: AppBar(
        title: const Text(
          'Sản phẩm yêu thích',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16122C),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          if (wishlistProvider.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Danh sách yêu thích trống',
                    style: TextStyle(fontSize: 18, color: Colors.white54),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lưu những sản phẩm bạn thích vào đây',
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: wishlistProvider.items.length,
            itemBuilder: (context, index) {
              final product = wishlistProvider.items[index];

              return Stack(
                children: [
                  ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  ),
                  // Nút xóa khỏi wishlist
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildCircleButton(
                      icon: Icons.close,
                      iconColor: Colors.redAccent,
                      onPressed: () {
                        wishlistProvider.removeFromWishlist(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Đã xóa khỏi danh sách yêu thích'),
                            backgroundColor: const Color(0xFF1E1A3A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ),
                  // Nút thêm vào giỏ hàng
                  Positioned(
                    bottom: 60,
                    right: 8,
                    child: _buildCircleButton(
                      icon: Icons.shopping_cart_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      onPressed: () async {
                        final user = authProvider.user;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Vui lòng đăng nhập'),
                              backgroundColor: const Color(0xFF1E1A3A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          return;
                        }

                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        await cartProvider.addToCart(
                          userId: user.id,
                          productId: product.id,
                          name: product.name,
                          imageUrl: product.images.isNotEmpty ? product.images.first : '',
                          price: product.finalPrice,
                          quantity: 1,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Đã thêm vào giỏ hàng'),
                            backgroundColor: const Color(0xFF1E1A3A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E1A3A),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}
