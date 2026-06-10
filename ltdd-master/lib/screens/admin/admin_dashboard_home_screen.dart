import 'dart:ui';
import 'package:doan_lttdd/screens/admin/product/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/admin_auth_provide.dart';
import 'package:doan_lttdd/provider/user_admin_provider.dart';
import 'package:doan_lttdd/provider/product_admin_provider.dart';
import 'package:doan_lttdd/screens/admin/user/user_list_screen.dart';
import 'package:doan_lttdd/screens/admin/order/order_list_screen.dart';
import 'package:doan_lttdd/screens/admin/analytics/analytics_screen.dart';
import 'package:doan_lttdd/models/order_model.dart';
import 'package:doan_lttdd/provider/order_provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/provider/chat_provider.dart';
import 'package:doan_lttdd/models/message_model.dart';
import 'package:doan_lttdd/screens/admin/admin_chat_screen.dart';

class AdminDashboardHomeScreen extends StatefulWidget {
  const AdminDashboardHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardHomeScreen> createState() => _AdminDashboardHomeScreenState();
}

class _AdminDashboardHomeScreenState extends State<AdminDashboardHomeScreen> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = true;

  @override
  Widget build(BuildContext context) {
    final adminAuth = context.read<AdminAuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      appBar: AppBar(
        leading: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              _isSidebarOpen ? Icons.menu_open_rounded : Icons.menu_rounded,
              key: ValueKey(_isSidebarOpen),
              color: Colors.white,
            ),
          ),
          tooltip: _isSidebarOpen ? 'Ẩn sidebar' : 'Hiện sidebar',
          onPressed: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              const LinearGradient(
                colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
              ).createShader(bounds),
          child: const Text(
            'Bảng Điều Khiển',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF16122C),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD946EF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD946EF).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Quản trị: ${adminAuth.adminName}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Theme(
            data: Theme.of(context).copyWith(cardColor: const Color(0xFF1E1A3A)),
            child: PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                PopupMenuItem<int>(
                  value: 0,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hồ sơ - Đang phát triển')),
                    );
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.person_outline_rounded, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text('Hồ sơ', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cài đặt - Đang phát triển')),
                    );
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.settings_outlined, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text('Cài đặt', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<int>(
                  value: 2,
                  onTap: () => _handleLogout(context, adminAuth),
                  child: Row(
                    children: const [
                      Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                      SizedBox(width: 8),
                      Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD946EF).withOpacity(0.05),
              ),
            ),
          ),
          Row(
            children: [
              // --- SIDEBAR với toggle animation ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                width: _isSidebarOpen ? 260 : 0,
                child: ClipRect(
                  child: OverflowBox(
                    minWidth: 0,
                    maxWidth: 260,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 260,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF120E25).withOpacity(0.6),
                          border: Border(
                            right: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
                          ),
                        ),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                                          ),
                                        ),
                                        child: const CircleAvatar(
                                          radius: 32,
                                          backgroundColor: Color(0xFF1A1632),
                                          child: Icon(
                                            Icons.admin_panel_settings_rounded,
                                            size: 36,
                                            color: Color(0xFFD946EF),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        adminAuth.adminName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        adminAuth.adminUser?.email ?? 'admin@cybershop.com',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                    children: [
                                      _buildNavItem(
                                        index: 0,
                                        icon: Icons.dashboard_rounded,
                                        label: 'Tổng quan',
                                        onTap: () => setState(() => _selectedIndex = 0),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildNavItem(
                                        index: 1,
                                        icon: Icons.people_alt_rounded,
                                        label: 'Quản lý người dùng',
                                        onTap: () => setState(() => _selectedIndex = 1),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildNavItem(
                                        index: 2,
                                        icon: Icons.shopping_basket_rounded,
                                        label: 'Quản lý sản phẩm',
                                        onTap: () => setState(() => _selectedIndex = 2),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildNavItem(
                                        index: 3,
                                        icon: Icons.receipt_long_rounded,
                                        label: 'Quản lý đơn hàng',
                                        onTap: () => setState(() => _selectedIndex = 3),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildNavItem(
                                        index: 4,
                                        icon: Icons.analytics_rounded,
                                        label: 'Thống kê',
                                        onTap: () => setState(() => _selectedIndex = 4),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildNavItem(
                                        index: 5,
                                        icon: Icons.chat_bubble_outline_rounded,
                                        label: 'Hỗ trợ khách hàng',
                                        onTap: () => setState(() => _selectedIndex = 5),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 46,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _handleLogout(context, adminAuth),
                                      icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                                      label: const Text(
                                        'ĐĂNG XUẤT',
                                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEF4444).withOpacity(0.15),
                                        side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // --- NỘI DUNG CHÍNH ---
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSelected
            ? LinearGradient(colors: [
          const Color(0xFFD946EF).withOpacity(0.2),
          const Color(0xFF8B5CF6).withOpacity(0.05),
        ])
            : null,
        border: isSelected ? Border.all(color: const Color(0xFFD946EF).withOpacity(0.4)) : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFD946EF) : Colors.white54,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildUserManagementContent();
      case 2:
        return _buildProductManagementContent();
      case 3:
        return _buildOrderManagementContent();
      case 4:
        return _buildAnalyticsContent();
      case 5:
        return _buildSupportChatContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildSupportChatContent() => const AdminChatScreen();
  Widget _buildUserManagementContent() => const UsersListScreen();
  Widget _buildProductManagementContent() => const ProductsListScreen();
  Widget _buildOrderManagementContent() => const OrdersListScreen();
  Widget _buildAnalyticsContent() => const AnalyticsScreen();

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan hệ thống',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            'Trạng thái điều khiển và giám sát ứng dụng.',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.4)),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: const [],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16122C).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Chỉ giữ 1 hàm _handleLogout duy nhất — phiên bản glassmorphism đẹp hơn
  void _handleLogout(BuildContext context, AdminAuthProvider adminAuth) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1A3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: const Text('Xác nhận đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Bạn có chắc muốn đăng xuất khỏi trang quản trị?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                adminAuth.logout();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}