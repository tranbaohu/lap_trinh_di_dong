import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/chat_provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/models/message_model.dart';
import 'package:intl/intl.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _adminId = 'admin'; // ID cố định nhận diện admin hệ thống

  @override
  void initState() {
    super.initState();
    // Chờ Build hoàn tất rồi mới kích hoạt lắng nghe luồng dữ liệu
    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());
  }

  void _initChat() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.user != null) {
      chatProvider.listenUserMessages(authProvider.user!.id);
      _scrollToBottom(isDelayed: true);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.user == null) return;

    _messageController.clear();

    await chatProvider.sendUserMessage(
      userId: authProvider.user!.id,
      userName: authProvider.user!.name,
      adminId: _adminId,
      content: text,
    );

    _scrollToBottom();
  }

  void _scrollToBottom({bool isDelayed = false}) {
    Future.delayed(Duration(milliseconds: isDelayed ? 300 : 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để trò chuyện')),
      );
    }

    // Tự động cuộn xuống cuối khi có tin nhắn mới đổ về Realtime
    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ Trợ Khách Hàng'),
        backgroundColor: const Color(0xFF1E1A33),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Khu vực hiển thị nội dung chat
          Expanded(
            child: chatProvider.messages.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 6),
                  Text('Hãy gửi tin nhắn để kết nối với bộ phận Admin nhé!', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.messages[index];

                // ĐỒNG BỘ LOGIC: Nếu tin nhắn KHÔNG PHẢI từ Admin -> là của User hiện tại (Hiện bên phải)
                final isMe = !message.isFromAdmin;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFD946EF) : const Color(0xFF1E1A33),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          // SỬA LỖI MÀU CHỮ: Luôn hiện màu trắng để không bị tàng hình trên nền tối
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('HH:mm').format(message.timestamp),
                          style: TextStyle(
                            fontSize: 9,
                            color: isMe ? Colors.white70 : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Thanh nhập text tin nhắn
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF151126),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung tin nhắn...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF1E1A33),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: const Color(0xFFD946EF),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}