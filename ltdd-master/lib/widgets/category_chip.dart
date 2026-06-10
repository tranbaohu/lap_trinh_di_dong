import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  String _getDisplayName(String category) {
    switch (category) {
      case "men's clothing":
        return "Men's Fashion";
      case "women's clothing":
        return "Women's Fashion";
      case 'Electronics':
        return 'Electronics';
      case 'Jewelery':
        return 'Jewelry';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            // ✅ FIX: Màu phù hợp dark theme, bỏ Colors.grey[100] sáng chói
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              // ✅ FIX: Bỏ Colors.grey[300], dùng white24 cho dark theme
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.18),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFD946EF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            _getDisplayName(label),
            style: TextStyle(
              // ✅ FIX: Bỏ Colors.black87, dùng white cho dark theme
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}