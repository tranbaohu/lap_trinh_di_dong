import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/product_admin_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // Định nghĩa mã màu Cyberpunk đồng bộ hệ thống
  static const Color _bgColor = Color(0xFF0F0C1B);         // Màu nền tối chủ đạo
  static const Color _cardColor = Color(0xFF17132A);       // Màu nền nhẹ cho ô nhập liệu
  static const Color _neonCyan = Color(0xFF00F5FF);        // Xanh Cyan Neon độc quyền cho Product
  static const Color _neonPurple = Color(0xFF8B5CF6);      // Tím Neon phối hợp

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _handleAddProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final productProvider = context.read<ProductAdminProvider>();

    final success = await productProvider.addProduct(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      discountPrice: double.parse(_discountPriceController.text),
      category: _categoryController.text.trim(),
      brand: _brandController.text.trim(),
      stock: int.parse(_stockController.text),
      imageUrl: _imageUrlController.text.trim(),
    );

    if (success) {
      // Refresh product list after adding
      await productProvider.refreshProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm sản phẩm thành công', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF10B981), // Neon Green
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage ?? 'Thêm sản phẩm thất bại', style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFEF4444), // Cyber Red
        ),
      );
    }
  }

  // Khung trang trí ô nhập liệu đã nâng cấp độ tương phản hiển thị rõ ràng trên nền tối
  InputDecoration _buildCyberInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: _neonCyan),
      filled: true,
      fillColor: _cardColor, // Thay thế lớp mờ bằng khối màu tối đặc để không bị tàng hình
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _neonCyan, width: 1.5),
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

      // --- APP BAR HIỆU ỨNG KÍNH MỜ ---
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_neonCyan, _neonPurple],
          ).createShader(bounds),
          child: const Text(
            'Thêm sản phẩm mới',
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

      // --- BODY THÂN FORM NHẬP LIỆU ---
      body: Consumer<ProductAdminProvider>(
        builder: (context, productProvider, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Container bọc các trường nhập thông tin
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
                          cursorColor: _neonCyan,
                          decoration: _buildCyberInputDecoration(
                            label: 'Tên sản phẩm',
                            hint: 'Nhập tên sản phẩm',
                            prefixIcon: Icons.shopping_bag_outlined,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập tên sản phẩm';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Description Field
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonCyan,
                          minLines: 3,
                          maxLines: 5,
                          decoration: _buildCyberInputDecoration(
                            label: 'Product Description',
                            hint: 'Enter technical or general specifications',
                            prefixIcon: Icons.description_outlined,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Khối chia đôi hàng cho Price và Discount Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                cursorColor: _neonCyan,
                                keyboardType: TextInputType.number,
                                decoration: _buildCyberInputDecoration(
                                  label: 'Original Price',
                                  hint: 'Value',
                                  prefixIcon: Icons.attach_money_rounded,
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  try {
                                    double.parse(value!);
                                  } catch (e) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: _discountPriceController,
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                cursorColor: _neonCyan,
                                keyboardType: TextInputType.number,
                                decoration: _buildCyberInputDecoration(
                                  label: 'Giá khuyến mãi',
                                  hint: 'Promo',
                                  prefixIcon: Icons.percent_rounded,
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  try {
                                    double.parse(value!);
                                  } catch (e) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Category Field
                        TextFormField(
                          controller: _categoryController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonCyan,
                          decoration: _buildCyberInputDecoration(
                            label: 'Danh mục',
                            hint: 'vd: Điện tử, Thời trang',
                            prefixIcon: Icons.category_outlined,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập danh mục';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Brand Field
                        TextFormField(
                          controller: _brandController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonCyan,
                          decoration: _buildCyberInputDecoration(
                            label: 'Thương hiệu',
                            hint: 'Nhập tên thương hiệu',
                            prefixIcon: Icons.gavel_rounded,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập thương hiệu';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Stock Quantity Field
                        TextFormField(
                          controller: _stockController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonCyan,
                          keyboardType: TextInputType.number,
                          decoration: _buildCyberInputDecoration(
                            label: 'Số lượng tồn kho',
                            hint: 'Nhập số lượng',
                            prefixIcon: Icons.inventory_2_outlined,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập số lượng';
                            }
                            try {
                              int.parse(value!);
                            } catch (e) {
                              return 'Nhập số nguyên';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Image URL Field
                        TextFormField(
                          controller: _imageUrlController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: _neonCyan,
                          decoration: _buildCyberInputDecoration(
                            label: 'Đường dẫn ảnh (không bắt buộc)',
                            hint: 'https://example.com/anh.png',
                            prefixIcon: Icons.link_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // --- NÚT SUBMIT ĐỒNG BỘ HIỆU ỨNG (NEON GRADIENT BUTTON) ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: productProvider.isLoading
                            ? null
                            : const LinearGradient(colors: [_neonCyan, _neonPurple]),
                        boxShadow: [
                          if (!productProvider.isLoading)
                            BoxShadow(
                              color: _neonCyan.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: productProvider.isLoading ? null : _handleAddProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.white12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: productProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Xác nhận thêm sản phẩm',
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

                  // --- PHẢN HỒI LỖI TỪ THÀNH PHẦN HỆ THỐNG ---
                  if (productProvider.errorMessage != null)
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
                                productProvider.errorMessage!,
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