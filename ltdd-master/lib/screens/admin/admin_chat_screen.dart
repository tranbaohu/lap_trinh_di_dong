import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/chat_provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/models/message_model.dart';
import 'package:intl/intl.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedUserId;
  String? _selectedUserName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).listenConversations();
    });
  }

  void _selectUser(String userId, String userName) {
    setState(() {
      _selectedUserId = userId;
      _selectedUserName = userName;
    });
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.listenAdminMessages(userId);
    _scrollToBottom(isDelayed: true);
  }

  // Bổ sung hàm để quay trở lại danh sách hội thoại trên Mobile
  void _backToConversations() {
    setState(() {
      _selectedUserId = null;
      _selectedUserName = null;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedUserId == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final adminId = authProvider.user?.id ?? 'admin';
    final adminName = authProvider.user?.name ?? 'Quản trị viên';

    _messageController.clear();

    await chatProvider.sendAdminMessage(
      userId: _selectedUserId!,
      adminId: adminId,
      adminName: adminName,
      content: text,
    );

    _scrollToBottom();
  }

  void _scrollToBottom({bool isDelayed = false}) {
    Future.delayed(Duration(milliseconds: isDelayed ? 300 : 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    if (_selectedUserId != null) {
      _scrollToBottom();
    }

    // Định dạng màu sắc chủ đạo đồng bộ với bản thiết kế cũ của bạn
    const backgroundColor = Color(0xFF151126);
    const itemColor = Color(0xFF1E1A33);
    const accentColor = Color(0xFF8B5CF6);

    // KIỂM TRA TRẠNG THÁI MÀN HÌNH ĐỂ BIỂU DIỄN GIAO DIỆN MOBILE
    // Nếu chưa chọn cuộc hội thoại -> Hiện danh sách khách hàng
    if (_selectedUserId == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: itemColor,
          elevation: 0,
          title: const Text(
            'Cuộc hội thoại của khách',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: chatProvider.conversations.isEmpty
            ? const Center(child: Text('Chưa có hội thoại', style: TextStyle(color: Colors.white38)))
            : ListView.builder(
          itemCount: chatProvider.conversations.length,
          itemBuilder: (context, index) {
            final conv = chatProvider.conversations[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF2E2A44),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                conv['userName'] ?? 'Ẩn danh',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                conv['lastMessage'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
              trailing: Text(
                DateFormat('HH:mm').format(conv['lastMessageTime']),
                style: const TextStyle(fontSize: 11, color: Colors.white30),
              ),
              onTap: () => _selectUser(conv['userId'], conv['userName'] ?? 'Khách hàng'),
            );
          },
        ),
      );
    }

    // Nếu đã chọn khách hàng -> Chuyển hoàn toàn sang không gian Chat chi tiết
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: itemColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _backToConversations, // Nút Back quay lại danh sách trên mobile
        ),
        title: Row(
          children: [
            const Icon(Icons.account_circle, color: accentColor, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedUserName ?? 'Khách hàng',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea( // Đảm bảo giao diện không đè lên tai thỏ/thanh điều hướng của điện thoại
        child: Column(
          children: [
            // Danh sách tin nhắn chi tiết
            Expanded(
              child: chatProvider.messages.isEmpty
                  ? const Center(child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messages[index];
                  final isAdmin = message.isFromAdmin;

                  return Align(
                    alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        // Tăng kích thước tối đa lên 75% chiều rộng màn hình để phù hợp với Mobile
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin ? accentColor : itemColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isAdmin ? 14 : 0),
                          bottomRight: Radius.circular(isAdmin ? 0 : 14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.content,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm').format(message.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: isAdmin ? Colors.white70 : Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Thanh nhập văn bản phản hồi dưới đáy màn hình
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: backgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn trả lời...',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                        filled: true,
                        fillColor: itemColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: accentColor,
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