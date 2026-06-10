import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/models/product_model.dart';
import 'package:doan_lttdd/provider/product_admin_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _categoryController;
  late TextEditingController _brandController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _discountPriceController = TextEditingController(text: widget.product.discountPrice.toString());
    _categoryController = TextEditingController(text: widget.product.category);
    _brandController = TextEditingController(text: widget.product.brand);
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _imageUrlController = TextEditingController(text: widget.product.images.join());
  }

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

  void _handleUpdateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final productProvider = context.read<ProductAdminProvider>();

    final success = await productProvider.updateProduct(
      productId: widget.product.id,
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
      // Refresh product list after editing
      await productProvider.refreshProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product core synchronized successfully'),
          backgroundColor: Color(0xFF10B981), // Neon Green
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage ?? 'Failed to update product node'),
          backgroundColor: const Color(0xFFEF4444), // Cyber Red
        ),
      );
    }
  }

  // Hàm xây dựng khung giao diện nhập liệu chuẩn Cyberpunk (Đồng bộ với Add Screen)
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
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF00F5FF)), // Neon Cyan làm chủ đạo
      filled: true,
      fillColor: Colors.white.withOpacity(0.02),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF00F5FF), width: 1.5),
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
      backgroundColor: Colors.transparent, // Thừa hưởng cấu trúc hình nền tối của hệ thống

      // --- APP BAR HIỆU ỨNG KÍNH MỜ ---
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00F5FF), Color(0xFF8B5CF6)],
          ).createShader(bounds),
          child: const Text(
            'Modify Product Node',
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

      // --- BODY THÂN FORM CHỈNH SỬA ---
      body: Consumer<ProductAdminProvider>(
        builder: (context, productProvider, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- PRODUCT ID READ-ONLY COMPONENT ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00F5FF).withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.terminal_rounded, color: Color(0xFF00F5FF), size: 18),
                        const SizedBox(width: 12),
                        Text(
                          'NODE_ID: ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                            fontSize: 13,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.product.id,
                            style: const TextStyle(
                              color: Color(0xFF00F5FF),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Courier',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Container bọc toàn bộ các trường nhập thông tin
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
                          cursorColor: const Color(0xFF00F5FF),
                          decoration: _buildCyberInputDecoration(
                            label: 'Tên sản phẩm',
                            hint: 'Modify core identification',
                            prefixIcon: Icons.shopping_bag_outlined,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Product name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Description Field
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: const Color(0xFF00F5FF),
                          minLines: 3,
                          maxLines: 5,
                          decoration: _buildCyberInputDecoration(
                            label: 'Product Description',
                            hint: 'Update data specifications',
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
                                cursorColor: const Color(0xFF00F5FF),
                                keyboardType: TextInputType.number,
                                decoration: _buildCyberInputDecoration(
                                  label: 'Original Price',
                                  hint: 'Value',
                                  prefixIcon: Icons.attach_money_rounded,
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Bắt buộc';
                                  }
                                  try {
                                    double.parse(value!);
                                  } catch (e) {
                                    return 'Không hợp lệ';
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
                                cursorColor: const Color(0xFF00F5FF),
                                keyboardType: TextInputType.number,
                                decoration: _buildCyberInputDecoration(
                                  label: 'Giá khuyến mãi',
                                  hint: 'Promo',
                                  prefixIcon: Icons.percent_rounded,
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Bắt buộc';
                                  }
                                  try {
                                    double.parse(value!);
                                  } catch (e) {
                                    return 'Không hợp lệ';
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
                          cursorColor: const Color(0xFF00F5FF),
                          decoration: _buildCyberInputDecoration(
                            label: 'System Category',
                            hint: 'Assign system tags',
                            prefixIcon: Icons.category_outlined,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Category is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Brand Field
                        TextFormField(
                          controller: _brandController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: const Color(0xFF00F5FF),
                          decoration: _buildCyberInputDecoration(
                            label: 'Manufacturer / Brand',
                            hint: 'Core system architect',
                            prefixIcon: Icons.gavel_rounded,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Brand is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Stock Quantity Field
                        TextFormField(
                          controller: _stockController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: const Color(0xFF00F5FF),
                          keyboardType: TextInputType.number,
                          decoration: _buildCyberInputDecoration(
                            label: 'Stock Units',
                            hint: 'Modify block cell capacity',
                            prefixIcon: Icons.inventory_2_outlined,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Stock is required';
                            }
                            try {
                              int.parse(value!);
                            } catch (e) {
                              return 'Enter integer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Image URL Field
                        TextFormField(
                          controller: _imageUrlController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: const Color(0xFF00F5FF),
                          decoration: _buildCyberInputDecoration(
                            label: 'Visual Source URL',
                            hint: 'https://matrix-resource.com/img.png',
                            prefixIcon: Icons.link_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- NÚT UPDATE (NEON GRADIENT BUTTON) ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: productProvider.isLoading
                            ? null
                            : const LinearGradient(colors: [Color(0xFF00F5FF), Color(0xFF8B5CF6)]),
                        boxShadow: [
                          if (!productProvider.isLoading)
                            BoxShadow(
                              color: const Color(0xFF00F5FF).withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: productProvider.isLoading ? null : _handleUpdateProduct,
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
                                'Commit Data Sync',
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
                  const SizedBox(height: 14),

                  // --- NÚT DELETE GIAO DIỆN GLITCH RED ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _showDeleteConfirm(context, productProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444).withOpacity(0.06),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.4), width: 1.2),
                      ),
                      child: const Text(
                        'Purge Product From Database',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
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

  // --- HỘP THOẠI XÁC NHẬN XÓA PHONG CÁCH CYBERPUNK DIALOG ---
  void _showDeleteConfirm(BuildContext context, ProductAdminProvider provider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF16122C).withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.4), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              const SizedBox(width: 10),
              const Text(
                'Purge Command',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
            ],
          ),
          content: Text(
            'Are you completely certain you want to destroy ${widget.product.name} from the terminal index?',
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Abort',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              child: ElevatedButton(
                onPressed: () {
                  provider.deleteProduct(widget.product.id);
                  Navigator.pop(context); // Đóng Dialog
                  Navigator.pop(context); // Thoát khỏi màn hình Edit
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product node successfully purged'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm Purge',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}