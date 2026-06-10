// File: lib/models/category_model.dart

class Category {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
