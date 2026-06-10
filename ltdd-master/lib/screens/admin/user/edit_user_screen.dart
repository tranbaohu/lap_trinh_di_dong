import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/models/user_model.dart';
import 'package:doan_lttdd/provider/user_admin_provider.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleUpdateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = context.read<UserAdminProvider>();

    final success = await userProvider.updateUser(
      userId: widget.user.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      isActive: _isActive,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.errorMessage ?? 'Cập nhật thất bại'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  InputDecoration _buildCyberInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF8B5CF6)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.02),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
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
      backgroundColor: Colors.transparent, // Thừa hưởng nền tối của hệ thống

      // --- APP BAR ĐỒNG BỘ HIỆU ỨNG KÍNH MỜ ---
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
          ).createShader(bounds),
          child: const Text(
            'Chỉnh sửa người dùng',
            style: TextStyle(
              fontWeight: FontWeight.w800,
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

      // --- KHU VỰC THÂN FORM CHỈNH SỬA ---
      body: Consumer<UserAdminProvider>(
        builder: (context, userProvider, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Khối hiển thị User ID (Read-only kiểu dữ liệu mật mã)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.fingerprint_rounded, color: Colors.white.withOpacity(0.4), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'MÃ ID: ',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            widget.user.id,
                            style: const TextStyle(
                              color: Color(0xFF00F5FF), // Màu Neon Cyan nổi bật
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier', // Tạo cảm giác mã hóa máy tính
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Khối bọc các trường chỉnh sửa dữ liệu chính
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.01),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Column(
                      children: [
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: const Color(0xFFD946EF),
                          decoration: _buildCyberInputDecoration(
                            label: 'Full Name',
                            hint: 'Edit user full name',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: const Color(0xFFD946EF),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildCyberInputDecoration(
                            label: 'Email Address',
                            hint: 'Edit email address',
                            prefixIcon: Icons.email_outlined,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Email is required';
                            }
                            if (!value!.contains('@')) {
                              return 'Enter valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: const Color(0xFFD946EF),
                          keyboardType: TextInputType.phone,
                          decoration: _buildCyberInputDecoration(
                            label: 'Phone Number',
                            hint: 'Update phone number',
                            prefixIcon: Icons.phone_android_rounded,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Address Field
                        TextFormField(
                          controller: _addressController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: const Color(0xFFD946EF),
                          minLines: 2,
                          maxLines: 4,
                          decoration: _buildCyberInputDecoration(
                            label: 'Resident Address',
                            hint: 'Update core address',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- THANH ĐIỀU CHỈNH TRẠNG THÁI HOẠT ĐỘNG ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isActive 
                            ? const Color(0xFF10B981).withOpacity(0.2) 
                            : const Color(0xFFEF4444).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isActive ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
                          color: _isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Account Status:',
                          style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() => _isActive = value);
                          },
                          activeColor: const Color(0xFF10B981),
                          activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
                          inactiveThumbColor: const Color(0xFFEF4444),
                          inactiveTrackColor: const Color(0xFFEF4444).withOpacity(0.2),
                        ),
                        Text(
                          _isActive ? 'HOẠT ĐỘNG' : 'KHÔNG HOẠT ĐỘNG',
                          style: TextStyle(
                            color: _isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // --- NÚT CẬP NHẬT CHÍNH (GRADIENT) ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: userProvider.isLoading 
                            ? null 
                            : const LinearGradient(colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)]),
                        boxShadow: [
                          if (!userProvider.isLoading)
                            BoxShadow(
                              color: const Color(0xFFD946EF).withOpacity(0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: userProvider.isLoading ? null : _handleUpdateUser,
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
                                'Lưu thay đổi',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // --- NÚT XÓA TÀI KHOẢN (NEON RED OUTLINE) ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => _showDeleteConfirm(context, userProvider),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        foregroundColor: const Color(0xFFEF4444),
                      ),
                      child: const Text(
                        'Xóa người dùng',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),

                  // Khối lỗi phản hồi hệ thống
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

  // --- HỘP THOẠI XÁC NHẬN XÓA CHUẨN ĐẸP CYBERPUNK ---
  void _showDeleteConfirm(BuildContext context, UserAdminProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1B4B).withOpacity(0.9), // Nền tối thẳm sâu
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFEF4444), width: 1.5), // Viền cảnh báo đỏ rực
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 26),
              const SizedBox(width: 10),
              const Text(
                'Cảnh báo xóa dữ liệu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              children: [
                const TextSpan(text: 'Bạn có chắc muốn xóa vĩnh viễn người dùng '),
                TextSpan(
                  text: widget.user.name,
                  style: const TextStyle(color: Color(0xFF00F5FF), fontWeight: FontWeight.w800),
                ),
                const TextSpan(text: ' khỏi hệ thống? Hành động này không thể hoàn tác.'),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white54),
              child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deleteUser(widget.user.id);
                Navigator.pop(context); // Đóng Dialog
                Navigator.pop(context); // Quay về trang List
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa người dùng'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                shadowColor: const Color(0xFFEF4444).withOpacity(0.4),
              ),
              child: const Text(
                'Xác nhận xóa',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}