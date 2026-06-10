import 'package:flutter/material.dart';
import 'package:doan_lttdd/services/firebase_chat_service.dart';
import 'package:doan_lttdd/models/message_model.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseChatService _chatService = FirebaseChatService();

  List<Message> _messages = [];
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isConnected = true;

  List<Message> get messages => _messages;
  List<Map<String, dynamic>> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _isConnected;

  // User: Lắng nghe tin nhắn realtime từ Admin
  void listenUserMessages(String userId) {
    _chatService.listenUserMessages(userId).listen(
          (messages) {
        _messages = messages;
        notifyListeners(); // Cập nhật màn hình User ngay lập tức khi có tin nhắn mới
      },
      onError: (error) {
        _errorMessage = 'Lỗi luồng tải tin nhắn khách: $error';
        notifyListeners();
      },
    );
  }

  // Admin: Lắng nghe danh sách tất cả các cuộc hội thoại (Inbox list)
  void listenConversations() {
    _chatService.getUserConversations().listen(
          (conversations) {
        _conversations = conversations;
        notifyListeners(); // Cập nhật danh sách chat bên trái của Admin khi có người nhắn tin mới
      },
      onError: (error) {
        _errorMessage = 'Lỗi danh sách hội thoại Admin: $error';
        notifyListeners();
      },
    );
  }

  // Admin: Lắng nghe tin nhắn chi tiết từ một user được chọn
  void listenAdminMessages(String userId) {
    _chatService.listenAdminMessages(userId).listen(
          (messages) {
        _messages = messages;
        notifyListeners(); // Cập nhật khung chat bên phải của Admin
      },
      onError: (error) {
        _errorMessage = 'Lỗi luồng tải tin nhắn phía Admin: $error';
        notifyListeners();
      },
    );
  }

  // User: Gửi tin nhắn đến admin
  Future<void> sendUserMessage({
    required String userId,
    required String userName,
    required String adminId,
    required String content,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _chatService.sendUserMessage(
        userId: userId,
        userName: userName,
        adminId: adminId,
        content: content,
      );

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gửi tin nhắn thất bại: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Admin: Gửi tin nhắn đến user
  Future<void> sendAdminMessage({
    required String userId,
    required String adminId,
    required String adminName,
    required String content,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _chatService.sendAdminMessage(
        userId: userId,
        adminId: adminId,
        adminName: adminName,
        content: content,
      );

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Admin gửi tin nhắn thất bại: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}