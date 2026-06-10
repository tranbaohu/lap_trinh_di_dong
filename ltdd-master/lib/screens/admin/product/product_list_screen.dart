import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/product_admin_provider.dart';
import 'package:doan_lttdd/screens/admin/product/add_product_srceen.dart';
import 'package:doan_lttdd/screens/admin/product/edit_product_screen.dart';
import 'package:doan_lttdd/models/product_model.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({Key? key}) : super(key: key);

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ProductAdminProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Không dùng Scaffold — đây là widget con trong dashboard
    return Consumer<ProductAdminProvider>(
      builder: (context, productProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + nút Add
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quản lý sản phẩm',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar dark
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1A3A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.3), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.3), size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            const SizedBox(height: 12),

            // Body
            Expanded(
              child: _buildBody(productProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(ProductAdminProvider productProvider) {
    if (productProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.purpleAccent),
      );
    }

    if (productProvider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('Chưa có sản phẩm nào', style: TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm sản phẩm đầu tiên'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }

    final filteredProducts = productProvider.products.where((product) {
      final name = product.name.toLowerCase();
      final brand = product.brand?.toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || brand.contains(q);
    }).toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy "${_searchController.text}"',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(context, product, productProvider);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, ProductAdminProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFF16122C),
              child: product.images != null && product.images.isNotEmpty
                  ? Image.network(
                product.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.white24,
                  size: 28,
                ),
              )
                  : const Icon(Icons.image_not_supported, color: Colors.white24, size: 28),
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.brand ?? ''} · ${product.category ?? ''}',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)} ₫',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD946EF),
                        fontSize: 13,
                      ),
                    ),
                    if (product.discountPrice != null && product.discountPrice > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${product.discountPrice.toStringAsFixed(0)} ₫',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Kho: ${product.stock}  ·  Đã bán: ${product.soldCount}',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.35)),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, size: 13, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu hành động
          Theme(
            data: Theme.of(context).copyWith(cardColor: const Color(0xFF1E1A3A)),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.4), size: 20),
              color: const Color(0xFF1E1A3A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              onSelected: (value) {
                if (value == 'view') {
                  _showProductDetail(context, product);
                } else if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
                  );
                } else if (value == 'delete') {
                  _showDeleteConfirm(context, provider, product);
                }
              },
              itemBuilder: (_) => [
                _menuItem('view', Icons.visibility_outlined, 'Xem chi tiết', Colors.white70),
                _menuItem('edit', Icons.edit_outlined, 'Chỉnh sửa', Colors.purpleAccent),
                _menuItem('delete', Icons.delete_outline, 'Xóa', Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  void _showProductDetail(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Thương hiệu', product.brand ?? '-'),
              _buildDetailRow('Danh mục', product.category ?? '-'),
              _buildDetailRow('Giá', '${product.price.toStringAsFixed(0)} ₫'),
              _buildDetailRow('Giá KM', '${product.discountPrice?.toStringAsFixed(0) ?? 0} ₫'),
              _buildDetailRow('Tồn kho', product.stock.toString()),
              _buildDetailRow('Đã bán', product.soldCount.toString()),
              _buildDetailRow('Đánh giá', product.rating.toStringAsFixed(1)),
              const SizedBox(height: 12),
              Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.7))),
              const SizedBox(height: 4),
              Text(product.description ?? '', style: const TextStyle(color: Colors.white60)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, ProductAdminProvider provider, dynamic product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: const Text('Xóa sản phẩm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc muốn xóa "${product.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () {
              provider.deleteProduct(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa sản phẩm'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}