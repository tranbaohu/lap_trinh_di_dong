import 'dart:ui';
import 'package:doan_lttdd/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/product_provider.dart';
import 'package:doan_lttdd/provider/product_admin_provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/provider/cart_provider.dart';
import 'package:doan_lttdd/screens/product_detail_screen.dart';
import 'package:doan_lttdd/screens/cart_screen.dart';
import 'package:doan_lttdd/screens/profile_screen.dart';
import 'package:doan_lttdd/screens/wishlist_screen.dart';
import 'package:doan_lttdd/widgets/product_card.dart';
import 'package:doan_lttdd/widgets/category_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<String> _categories = [
    'All',
    'Electronics',
    'Fashion',
    "men's clothing",
    "women's clothing",
    'jewelery',
  ];

  String _selectedCategory = 'All';
  bool _isInitialized = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final productAdminProvider = Provider.of<ProductAdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    await Future.wait([
      productProvider.loadProducts(),
      productAdminProvider.refreshProducts(),
    ]);

    if (authProvider.user != null) {
      await productProvider.loadRecommendedProducts(authProvider.user!.id);
      await cartProvider.loadCart(authProvider.user!.id);
    }
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD946EF).withOpacity(0.14),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.12),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 85, sigmaY: 85),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(),
                const WishlistScreen(),
                const CartScreen(),
                const ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAnimatedTabItem(0, Icons.home_rounded, 'Trang chủ'),
                  _buildAnimatedTabItem(1, Icons.favorite_rounded, 'Yêu thích'),
                  _buildAnimatedTabItem(2, Icons.shopping_cart_rounded, 'Giỏ hàng'),
                  _buildAnimatedTabItem(3, Icons.person_rounded, 'Cá nhân'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? LinearGradient(
            colors: [
              const Color(0xFFD946EF).withOpacity(0.25),
              const Color(0xFF8B5CF6).withOpacity(0.15),
            ],
          )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? const Color(0xFFD946EF) : Colors.white54,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? 70 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<ProductProvider>(
      builder: (context, userProvider, child) {
        return Consumer<ProductAdminProvider>(
          builder: (context, adminProvider, child) {
            final List<Product> apiProducts = userProvider.products;
            final List<Product> adminProducts = adminProvider.products;

            final Map<String, Product> mergedMap = {};
            for (var p in apiProducts) {
              mergedMap[p.id] = p;
            }
            for (var p in adminProducts) {
              mergedMap[p.id] = p;
            }
            final List<Product> allProducts = mergedMap.values.toList();

            final categoryFiltered = allProducts.where((product) {
              if (_selectedCategory == 'All') return true;
              return product.category.toLowerCase() == _selectedCategory.toLowerCase();
            }).toList();

            final filteredBySearch = categoryFiltered.where((product) {
              return _searchQuery.isEmpty ||
                  product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  product.description.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            if ((userProvider.isLoading || adminProvider.isLoading) && allProducts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD946EF))),
                    SizedBox(height: 16),
                    Text('Đang tải dữ liệu...', style: TextStyle(color: Colors.white60)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: const Color(0xFFD946EF),
              backgroundColor: const Color(0xFF1E1A33),
              onRefresh: _loadData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBar(),
                  _buildSearchBar(),
                  _buildCategorySection(),
                  if (_searchQuery.isNotEmpty)
                    _buildSearchResultSection(filteredBySearch)
                  else ...[
                    _buildRecommendedSection(userProvider.recommendedProducts.isNotEmpty
                        ? userProvider.recommendedProducts
                        : allProducts),
                    _buildAllProductsSection(filteredBySearch),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            background: !_isSearching
                ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD946EF).withOpacity(0.2),
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt,
                        size: 40, color: Color(0xFFD946EF)),
                    const SizedBox(height: 6),
                    const Text(
                      'SIÊU KHUYẾN MÃI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Text(
                      'Đồng bộ Cloud & Local',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                      ).createShader(bounds),
                      child: const Text(
                        'ShopEasy',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 26,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : null,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: Colors.white),
            onPressed: _toggleSearch,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    if (!_isSearching) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon:
                  const Icon(Icons.search_rounded, color: Color(0xFFD946EF)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                    onPressed: _clearSearch,
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Danh mục',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return CategoryChip(
                  label: category,
                  isSelected: _selectedCategory == category,
                  onTap: () => _filterByCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchResultSection(List<Product> products) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  'Không tìm thấy sản phẩm cho "$_searchQuery"',
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearSearch,
                  child: const Text('Xóa tìm kiếm',
                      style: TextStyle(color: Color(0xFFD946EF))),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= products.length) return const SizedBox.shrink();
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => _navigateToProductDetail(product),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildRecommendedSection(List<Product> recommendedProducts) {
    final recommended = recommendedProducts.take(5).toList();

    if (recommended.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Gợi ý cho bạn',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: recommended.length,
              itemBuilder: (context, index) {
                final product = recommended[index];
                return Container(
                  width: 165,
                  margin: const EdgeInsets.only(right: 14),
                  child: ProductCard(
                    product: product,
                    onTap: () => _navigateToProductDetail(product),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAllProductsSection(List<Product> products) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.inventory_2_rounded, size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text('Không có sản phẩm nào', style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= products.length) return const SizedBox.shrink();
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => _navigateToProductDetail(product),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}