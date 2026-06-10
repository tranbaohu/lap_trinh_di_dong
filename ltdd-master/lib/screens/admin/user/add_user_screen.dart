import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/user_admin_provider.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _showPassword = false;

  // Bảng màu hệ thống Cyberpunk đồng bộ với toàn bộ ứng dụng
  static const Color _bgColor = Color(0xFF0F0C1B);         // Màu nền tối chủ đạo chống trắng màn hình
  static const Color _cardColor = Color(0xFF17132A);       // Màu nền khối đặc cho trường nhập liệu
  static const Color _neonPink = Color(0xFFD946EF);        // Hồng Neon đặc trưng cho User Management
  static const Color _neonPurple = Color(0xFF8B5CF6);      // Tím Cyber phối hợp

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleAddUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = context.read<UserAdminProvider>();

    final success = await userProvider.addUser(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm người dùng thành công', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF10B981), // Neon Green hệ thống
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.errorMessage ?? 'Thêm người dùng thất bại', style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFEF4444), // Cyber Red
        ),
      );
    }
  }

  // Hàm tạo Style ô nhập liệu với độ tương phản cao, không lo bị lóa hay tàng hình
  InputDecoration _buildCyberInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: _neonPurple),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _cardColor, // Đổi từ độ mờ transparent sang khối màu đặc chống lỗi hiển thị
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _neonPink, width: 1.5), // Focus sáng bừng hồng neon
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor, // 🟢 Đã gán trực tiếp mã màu tối để xử lý triệt để lỗi nền trắng

      // --- APP BAR ĐỒNG BỘ HIỆU ỨNG KÍNH MỜ ---
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_neonPink, _neonPurple],
          ).createShader(bounds),
          child: const Text(
            'Thêm người dùng mới',
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
        backgroundColor: const Color(0xFF16122C).withOpacity(0.4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),

      // --- KHU VỰC THÂN FORM NHẬP LIỆU ---
      body: Consumer<UserAdminProvider>(
        builder: (context, userProvider, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Khối bọc các Input tạo chiều sâu kĩ thuật số
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonPink,
                          decoration: _buildCyberInputDecoration(
                            label: 'Họ và tên',
                            hint: 'Nhập họ tên đầy đủ',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập họ tên';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonPink,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildCyberInputDecoration(
                            label: 'Email',
                            hint: 'ten@email.com',
                            prefixIcon: Icons.email_outlined,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập email';
                            }
                            if (!value!.contains('@')) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonPink,
                          decoration: _buildCyberInputDecoration(
                            label: 'Mật khẩu',
                            hint: 'Tối thiểu 6 ký tự',
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() => _showPassword = !_showPassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value!.length < 6) {
                              return 'Mật khẩu tối thiểu 6 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonPink,
                          keyboardType: TextInputType.phone,
                          decoration: _buildCyberInputDecoration(
                            label: 'Số điện thoại',
                            hint: 'Nhập số điện thoại',
                            prefixIcon: Icons.phone_android_rounded,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Address Field
                        TextFormField(
                          controller: _addressController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonPink,
                          minLines: 2,
                          maxLines: 4,
                          decoration: _buildCyberInputDecoration(
                            label: 'Địa chỉ (không bắt buộc)',
                            hint: 'Nhập địa chỉ',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // --- NÚT SUBMIT GRADIENT CYBERPUNK ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: userProvider.isLoading 
                            ? null 
                            : const LinearGradient(colors: [_neonPink, _neonPurple]),
                        boxShadow: [
                          if (!userProvider.isLoading)
                            BoxShadow(
                              color: _neonPink.withOpacity(0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: userProvider.isLoading ? null : _handleAddUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, 
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.white12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: userProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Xác nhận thêm người dùng',
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

                  // Khối thông báo lỗi từ Provider (Nếu có)
                  if (userProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                userProvider.errorMessage!,
                                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}