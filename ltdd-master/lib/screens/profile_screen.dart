import 'dart:ui';
import 'dart:io'; // Bổ sung import để đọc File ảnh cục bộ đường dẫn SQLite
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/provider/order_provider.dart';
import 'package:doan_lttdd/screens/orders_screen.dart';
import 'package:doan_lttdd/screens/edit_profile_screen.dart';
import 'package:doan_lttdd/screens/chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _bgColor = Color(0xFF0F0C1B);
  static const Color _cardColor = Color(0xFF17132A);
  static const Color _neonPink = Color(0xFFD946EF);
  static const Color _neonPurple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: _bgColor,
      body: RefreshIndicator(
        color: _neonPink,
        backgroundColor: _cardColor,
        onRefresh: () async {
          if (user != null) {
            await orderProvider.loadOrders(user.id);
          }
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ---- APP BAR ----
            SliverAppBar(
              backgroundColor: _bgColor,
              expandedHeight: 200,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Neon glow blobs
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _neonPink.withOpacity(0.10),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _neonPurple.withOpacity(0.10),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    // Avatar + info
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [_neonPink, _neonPurple],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: _cardColor,
                              // CHỈNH SỬA TOÀN DIỆN PHÂN ĐOẠN ĐỌC ĐƯỜNG DẪN ẢNH TỪ FILE VÀ MẠNG
                              child: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                                  ? ClipOval(
                                child: user.avatarUrl!.startsWith('http')
                                    ? Image.network(
                                  user.avatarUrl!,
                                  width: 76,
                                  height: 76,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Colors.white54),
                                )
                                    : Image.file(
                                  File(user.avatarUrl!),
                                  width: 76,
                                  height: 76,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Colors.white54),
                                ),
                              )
                                  : const Icon(Icons.person, size: 40, color: Colors.white54),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Người dùng',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                // Points badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _neonPink.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _neonPink.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, size: 14, color: _neonPink),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${user?.points ?? 0} điểm',
                                        style: const TextStyle(
                                          color: _neonPink,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              title: const Text(
                'Trang cá nhân',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            // ---- STATS ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.shopping_bag_rounded,
                        title: 'Đơn hàng',
                        value: orderProvider.orders.length.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.star_rounded,
                        title: 'Điểm tích lũy',
                        value: user?.points.toString() ?? '0',
                        accent: _neonPink,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ---- SECTION LABEL ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'TÀI KHOẢN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ---- MENU ITEMS ----
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Đơn hàng của tôi',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Chỉnh sửa hồ sơ',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Tin nhắn',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserChatScreen())),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.credit_card_outlined,
                      title: 'Phương thức thanh toán',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Địa chỉ giao hàng',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Hỗ trợ & Trợ giúp',
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ---- LOGOUT ----
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.18)),
                ),
                child: _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Đăng xuất',
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  isDestructive: true,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.construction_rounded, color: _neonPink, size: 18),
            SizedBox(width: 10),
            Text('Tính năng đang phát triển', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: _cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    Color accent = _neonPurple,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: accent),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : Colors.white70;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.04),
      indent: 50,
    );
  }
}