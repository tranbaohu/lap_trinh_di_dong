import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doan_lttdd/models/message_model.dart';

class FirebaseChatService {
  // Đổi từ Realtime Database sang Cloud Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. USER: Gửi tin nhắn đến admin
  Future<void> sendUserMessage({
    required String userId,
    required String userName,
    required String adminId,
    required String content,
  }) async {
    final chatDocRef = _firestore.collection('chats').doc(userId);
    final messageCollectionRef = chatDocRef.collection('messages');
    final messageId = messageCollectionRef.doc().id;

    // Gửi map dữ liệu lên Firestore, dùng FieldValue.serverTimestamp() của Google
    await messageCollectionRef.doc(messageId).set({
      'id': messageId,
      'senderId': userId,
      'senderName': userName,
      'receiverId': adminId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(), // Đồng bộ chuẩn Timestamp
      'isRead': false,
      'isFromAdmin': false,
    });

    // Cập nhật sảnh chờ danh sách chat của Admin
    await chatDocRef.set({
      'userId': userId,
      'userName': userName,
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 2. ADMIN: Gửi tin nhắn đến user
  Future<void> sendAdminMessage({
    required String userId,
    required String adminId,
    required String adminName,
    required String content,
  }) async {
    final chatDocRef = _firestore.collection('chats').doc(userId);
    final messageCollectionRef = chatDocRef.collection('messages');
    final messageId = messageCollectionRef.doc().id;

    await messageCollectionRef.doc(messageId).set({
      'id': messageId,
      'senderId': adminId,
      'senderName': adminName,
      'receiverId': userId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(), // Đồng bộ chuẩn Timestamp
      'isRead': false,
      'isFromAdmin': true,
    });

    // Cập nhật lại tin nhắn cuối cùng hiển thị ở danh sách sảnh chờ
    await chatDocRef.set({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 3. USER: Lắng nghe tin nhắn realtime từ Admin đổ về
  Stream<List<Message>> listenUserMessages(String userId) {
    return _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Sắp xếp thời gian tăng dần
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromFirebase(doc.data(), doc.id);
      }).toList();
    });
  }

  // 4. ADMIN: Lắng nghe tin nhắn từ một user cụ thể
  Stream<List<Message>> listenAdminMessages(String userId) {
    return _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromFirebase(doc.data(), doc.id);
      }).toList();
    });
  }

  // 5. ADMIN: Lắng nghe danh sách tất cả các cuộc hội thoại ở sảnh chờ
  Stream<List<Map<String, dynamic>>> getUserConversations() {
    return _firestore
        .collection('chats')
        .orderBy('lastMessageTime', descending: true) // Cuộc gọi mới nhất lên đầu
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        DateTime parsedTime = DateTime.now();

        // Kiểm tra và ép kiểu an toàn trường thời gian sang DateTime
        if (data['lastMessageTime'] != null && data['lastMessageTime'] is Timestamp) {
          parsedTime = (data['lastMessageTime'] as Timestamp).toDate();
        }

        return {
          'userId': doc.id,
          'userName': data['userName'] ?? 'Khách hàng',
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': parsedTime,
        };
      }).toList();
    });
  }
}