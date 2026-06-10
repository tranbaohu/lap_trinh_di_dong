class User {
  final String id;
  final String email;
  String name;
  String? avatarUrl;
  int points;
  String? phone;
  String? address;
  String role;
  bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.points = 0,
    this.phone,
    this.address,
    this.role = 'user',
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl ?? '',
      'points': points,
      'phone': phone ?? '',
      'address': address ?? '',
      'role': role,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      points: json['points'] ?? 0,
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      isActive:
      json['isActive'] == 1 ||
          json['isActive'] == true,
      createdAt:
      json['createdAt'] != null
          ? DateTime.parse(
        json['createdAt'],
      )
          : DateTime.now(),
    );
  }
}