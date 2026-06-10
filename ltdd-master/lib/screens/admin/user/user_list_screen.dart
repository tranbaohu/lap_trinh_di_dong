import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/user_admin_provider.dart';
import 'package:doan_lttdd/screens/admin/user/add_user_screen.dart';
import 'package:doan_lttdd/screens/admin/user/edit_user_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    // ✨ Tải lại dữ liệu mỗi khi vào màn hình từ database
    Future.microtask(() {
      context.read<UserAdminProvider>().refreshUsers();
    });
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
            'Quản lý người dùng',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
              fontSize: 20,
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
      ),

      // --- NÚT THÊM USER PHONG CÁCH NEON RỰC RỠ ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddUserScreen()),
          );
        },
        backgroundColor: const Color(0xFFD946EF),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tooltip: 'Thêm người dùng mới',
        child: const Icon(Icons.person_add, color: Colors.white),
      ),

      // --- PHẦN BODY QUẢN LÝ DANH SÁCH ---
      body: Consumer<UserAdminProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD946EF)),
              ),
            );
          }

          // Trạng thái trống danh sách người dùng
          if (userProvider.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: const Color(0xFF8B5CF6).withOpacity(0.4)),
                  const SizedBox(height: 20),
                  const Text(
                    'Chưa có người dùng nào',
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddUserScreen()),
                      );
                    },
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text('Thêm người dùng đầu tiên', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          // Danh sách các thẻ User cao cấp
          return RefreshIndicator(
            color: const Color(0xFFD946EF),
            backgroundColor: const Color(0xFF1E1A3A),
            onRefresh: () => userProvider.refreshUsers(),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                final user = userProvider.users[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03), // Khối kính mờ
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: user.isActive 
                          ? const Color(0xFF10B981).withOpacity(0.15) // Viền xanh lá mờ nếu Active
                          : const Color(0xFFEF4444).withOpacity(0.15), // Viền đỏ mờ nếu Inactive
                      width: 1.2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // Trạng thái hoạt động bọc vòng tròn tỏa sáng nhẹ
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user.isActive 
                            ? const Color(0xFF10B981).withOpacity(0.1) 
                            : const Color(0xFFEF4444).withOpacity(0.1),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          user.isActive ? Icons.check_circle_outline_rounded : Icons.gpp_bad_rounded,
                          color: user.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: 28,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Email: ${user.email}',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Trạng thái: ',
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                            ),
                            Text(
                              user.isActive ? "Hoạt động" : "Không hoạt động",
                              style: TextStyle(
                                color: user.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Nút Menu chức năng tùy biến icon màu neon trắng
                    trailing: Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: const Color(0xFF1E1A3A), // Nền của popup menu mượt với hệ thống
                      ),
                      child: PopupMenuButton(
                        icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withOpacity(0.08)),
                        ),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            onTap: () {
                              userProvider.selectUser(user);
                              // Sử dụng Future.delayed để tránh xung đột vòng lặp dựng giao diện của showDialog
                              Future.delayed(Duration.zero, () => _showUserDetail(context, user));
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.visibility_rounded, color: Colors.white70, size: 20),
                                SizedBox(width: 10),
                                Text('View', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              Future.delayed(Duration.zero, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditUserScreen(user: user),
                                  ),
                                );
                              });
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.edit_rounded, color: Color(0xFF8B5CF6), size: 20),
                                SizedBox(width: 10),
                                Text('Edit', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              Future.delayed(Duration.zero, () => _toggleUserStatus(context, userProvider, user.id));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  user.isActive ? Icons.block_rounded : Icons.check_circle_rounded, 
                                  color: user.isActive ? const Color(0xFFF59E0B) : const Color(0xFF10B981), 
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt', 
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              Future.delayed(Duration.zero, () => _showDeleteConfirm(context, userProvider, user));
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 20),
                                SizedBox(width: 10),
                                Text('Xóa', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // --- HỘP THOẠI XEM CHI TIẾT USER ---
  void _showUserDetail(BuildContext context, dynamic user) {
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
          title: Text(
            user.name, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Email', user.email),
                _buildDetailRow('Điện thoại', user.phone ?? 'N/A'),
                _buildDetailRow('Địa chỉ', user.address ?? 'N/A'),
                _buildDetailRow('Điểm', user.points.toString()),
                _buildDetailRow(
                  'Trạng thái',
                  user.isActive ? 'Active' : 'Inactive',
                  isStatus: true,
                  statusValue: user.isActive,
                ),
                _buildDetailRow(
                  'Ngày tạo',
                  '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Color(0xFFD946EF), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false, bool statusValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isStatus 
                    ? (statusValue ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                    : Colors.white,
                fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HỘP THOẠI THAY ĐỔI TRẠNG THÁI USER ---
  void _toggleUserStatus(BuildContext context, UserAdminProvider provider, String userId) {
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
          title: const Text('Thay đổi trạng thái', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Bạn có chắc chắn muốn thay đổi trạng thái hoạt động của tài khoản này?', style: TextStyle(color: Colors.white60)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {
                provider.toggleUserStatus(userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật trạng thái thành công'),
                    backgroundColor: Color(0xFF16122C),
                  ),
                );
              },
              child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- HỘP THOẠI XÁC NHẬN XÓA USER ---
  void _showDeleteConfirm(BuildContext context, UserAdminProvider provider, dynamic user) {
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
          title: const Text('Xóa người dùng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('Hành động này không thể hoàn tác. Bạn có chắc muốn xóa vĩnh viễn người dùng ${user.name}?', style: const TextStyle(color: Colors.white60)),
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
              onPressed: () {
                provider.deleteUser(user.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa người dùng'),
                    backgroundColor: Color(0xFF16122C),
                  ),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}