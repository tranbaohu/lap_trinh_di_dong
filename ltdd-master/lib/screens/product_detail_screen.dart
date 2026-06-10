import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doan_lttdd/models/product_model.dart';
import 'package:doan_lttdd/provider/cart_provider.dart';
import 'package:doan_lttdd/provider/wishlist_provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/screens/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedQuantity = 1;
  int _currentImageIndex = 0;
  bool _isAddingToCart = false;

  static const Color _bgColor = Color(0xFF0F0C1B);
  static const Color _cardColor = Color(0xFF17132A);
  static const Color _neonPink = Color(0xFFD946EF);
  static const Color _neonPurple = Color(0xFF8B5CF6);

  Future<void> _handleAddToCart() async {
    if (_isAddingToCart) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: _cardColor,
          content: Text('Vui lòng đăng nhập để thêm vào giỏ hàng',
              style: TextStyle(color: Colors.white)),
        ),
      );
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      await Future.microtask(() => cartProvider.addToCart(
        userId: user.id,
        productId: widget.product.id,
        name: widget.product.name,
        imageUrl:
        widget.product.images.isNotEmpty ? widget.product.images.first : '',
        price: widget.product.finalPrice,
        quantity: _selectedQuantity,
      ));

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: _cardColor,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(12),
            content: Text(
              'Đã thêm $_selectedQuantity ${widget.product.name} vào giỏ hàng',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            action: SnackBarAction(
              label: 'Xem giỏ',
              textColor: _neonPink,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            ),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.9),
          content: Text('Thêm vào giỏ hàng thất bại: $e',
              style: const TextStyle(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images;

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _bgColor,
            expandedHeight: 300,
            pinned: true,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  if (images.isNotEmpty)
                    PageView.builder(
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withOpacity(0.05),
                            child: const Center(
                              child: CircularProgressIndicator(color: _neonPink),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withOpacity(0.05),
                            child: const Icon(Icons.error, color: Colors.white38),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.white.withOpacity(0.05),
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 60, color: Colors.white38),
                      ),
                    ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? _neonPink
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              Consumer<WishlistProvider>(
                builder: (context, wishlistProvider, child) {
                  final isInWishlist =
                  wishlistProvider.isInWishlist(widget.product.id);

                  return IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      if (isInWishlist) {
                        wishlistProvider.removeFromWishlist(widget.product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: _cardColor,
                            content: Text('Đã xóa khỏi yêu thích',
                                style: TextStyle(color: Colors.white)),
                          ),
                        );
                      } else {
                        wishlistProvider.addToWishlist(widget.product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: _cardColor,
                            content: Text('Đã thêm vào yêu thích',
                                style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${widget.product.soldCount} đã bán)',
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const Spacer(),
                      if (widget.product.brand != null)
                        Text(
                          widget.product.brand!,
                          style: const TextStyle(
                              color: _neonPurple, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.product.hasDiscount) ...[
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.white38,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '\$${widget.product.finalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _neonPink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.product.hasDiscount)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${((widget.product.price - widget.product.finalPrice) / widget.product.price * 100).toInt()}% GIẢM',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(height: 1.5, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  const Text(
                    'Số lượng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _cardColor,
                          border:
                          Border.all(color: Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.white),
                              onPressed: _selectedQuantity > 1
                                  ? () {
                                setState(() {
                                  _selectedQuantity--;
                                });
                              }
                                  : null,
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$_selectedQuantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: _selectedQuantity < widget.product.stock
                                  ? () {
                                setState(() {
                                  _selectedQuantity++;
                                });
                              }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Còn ${widget.product.stock} sản phẩm',
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                  if (widget.product.stock <= 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Hết hàng',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _bgColor,
          border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: (widget.product.stock > 0 && !_isAddingToCart)
                    ? const LinearGradient(
                    colors: [_neonPurple, _neonPink])
                    : null,
                boxShadow: [
                  if (widget.product.stock > 0 && !_isAddingToCart)
                    BoxShadow(
                      color: _neonPink.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.product.stock > 0 && !_isAddingToCart
                    ? _handleAddToCart
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}