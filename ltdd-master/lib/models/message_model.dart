import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file }

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isFromAdmin;
  final String? imageUrl;
  final MessageType type;

  Message({
    required this.id,
    required this.senderId,
    this.senderName = '',
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isFromAdmin = false,
    this.imageUrl,
    this.type = MessageType.text,
  });

  // Chuyển đổi Model sang JSON để đẩy lên Firebase
  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'receiverId': receiverId,
    'content': content,
    // Lưu ý: Khi đẩy trực tiếp từ model, ta dùng thời gian hệ thống hoặc FieldValue ở Service
    'timestamp': timestamp.millisecondsSinceEpoch,
    'isRead': isRead,
    'isFromAdmin': isFromAdmin,
    'imageUrl': imageUrl,
    'type': type.index,
  };

  // Hàm bóc tách dữ liệu Realtime từ Cloud Firestore về Model App một cách an toàn
  factory Message.fromFirebase(Map<String, dynamic> json, String id) {
    DateTime parsedTimestamp = DateTime.now();

    if (json['timestamp'] != null) {
      if (json['timestamp'] is Timestamp) {
        // 1. Trường hợp là kiểu dữ liệu Timestamp chính chủ của Cloud Firestore
        parsedTimestamp = (json['timestamp'] as Timestamp).toDate();
      } else if (json['timestamp'] is int) {
        // 2. Trường hợp là kiểu số nguyên Epoch từ dữ liệu cũ hoặc từ các hàm test
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int);
      } else {
        // 3. Trường hợp là chuỗi String hoặc định dạng ngày tháng khác
        parsedTimestamp = DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now();
      }
    }

    // Xác định kiểu tin nhắn (Text, Image hoặc File)
    MessageType parsedType = MessageType.text;
    if (json['type'] != null) {
      final typeIndex = json['type'] as int;
      if (typeIndex >= 0 && typeIndex < MessageType.values.length) {
        parsedType = MessageType.values[typeIndex];
      }
    }

    return Message(
      id: id,
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      timestamp: parsedTimestamp,
      isRead: json['isRead'] ?? false,
      isFromAdmin: json['isFromAdmin'] ?? false,
      imageUrl: json['imageUrl']?.toString(),
      type: parsedType,
    );
  }
}