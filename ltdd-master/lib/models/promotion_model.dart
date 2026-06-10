class Promotion {
  final String id;
  final String code;
  final String type; // 'percent' hoặc 'fixed'
  final double value;
  final double? minAmount;
  final int? maxUsage;
  final int usageCount;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime createdAt;
 
  Promotion({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.minAmount,
    this.maxUsage,
    this.usageCount = 0,
    this.expiryDate,
    this.isActive = true,
    required this.createdAt,
  });
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'type': type,
        'value': value,
        'minAmount': minAmount,
        'maxUsage': maxUsage,
        'usageCount': usageCount,
        'expiryDate': expiryDate?.toIso8601String(),
        'isActive': isActive ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
      };
 
  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        id: json['id'],
        code: json['code'],
        type: json['type'],
        value: (json['value'] as num).toDouble(),
        minAmount: json['minAmount'] != null
            ? (json['minAmount'] as num).toDouble()
            : null,
        maxUsage: json['maxUsage'],
        usageCount: json['usageCount'] ?? 0,
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : null,
        isActive: json['isActive'] == 1 || json['isActive'] == true,
        createdAt: DateTime.parse(json['createdAt']),
      );
}