import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doan_lttdd/models/product_model.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = widget.product.stock <= 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered && !isOutOfStock ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTap: isOutOfStock ? null : widget.onTap,
          // ✅ FIX 1: Bỏ ClipRRect + BackdropFilter gây crash GPU trên Android emulator
          // Thay bằng Container với decoration thuần, giữ nguyên visual dark/glass
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered && !isOutOfStock
                    ? const Color(0xFFD946EF).withOpacity(0.5)
                    : Colors.white.withOpacity(0.10),
                width: 1,
              ),
              boxShadow: _isHovered && !isOutOfStock
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD946EF).withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KHU VỰC ẢNH SẢN PHẨM ---
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        AnimatedScale(
                          scale: _isHovered && !isOutOfStock ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: CachedNetworkImage(
                            imageUrl: widget.product.images.isNotEmpty
                                ? widget.product.images.first
                                : '',
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFF1E1A33),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFD946EF)),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFF1E1A33),
                              child: const Icon(Icons.broken_image_outlined,
                                  color: Colors.white24, size: 32),
                            ),
                          ),
                        ),
                        // Gradient overlay che chân ảnh
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xB20F0C1B),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // BADGE SALE
                        if (widget.product.hasDiscount)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF007A),
                                    Color(0xFFD946EF)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFFFF007A).withOpacity(0.3),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                              child: const Text(
                                'SALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        // BADGE OUT OF STOCK
                        if (isOutOfStock)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.white24, width: 0.5),
                              ),
                              child: const Text(
                                'SOLDOUT',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // --- KHU VỰC THÔNG TIN SẢN PHẨM ---
                  // ✅ FIX 2: Bỏ Expanded + Spacer → dùng Column với mainAxisAlignment.spaceBetween
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tên sản phẩm
                          Text(
                            widget.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              height: 1.3,
                              color: isOutOfStock
                                  ? Colors.white38
                                  : Colors.white70,
                            ),
                          ),

                          // Giá + Rating
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dòng giá tiền
                              Row(
                                children: [
                                  if (widget.product.hasDiscount) ...[
                                    Text(
                                      '\$${widget.product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.white30,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Flexible(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Color(0xFFD946EF),
                                          Color(0xFF8B5CF6)
                                        ],
                                      ).createShader(bounds),
                                      child: Text(
                                        '\$${widget.product.finalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isOutOfStock
                                              ? Colors.white38
                                              : Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Dòng rating + đã bán
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 14, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.white70),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Đã bán ${widget.product.soldCount}',
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.white38),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}