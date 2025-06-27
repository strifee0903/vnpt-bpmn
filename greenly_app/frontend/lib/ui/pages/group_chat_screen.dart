import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class GroupChatScreen extends StatefulWidget {
  final String campaignTitle;
  final List<Map<String, String>> participants;

  const GroupChatScreen({
    super.key,
    required this.campaignTitle,
    required this.participants,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final List<types.Message> _messages = [];
  late final types.User _currentUser;

  @override
  void initState() {
    super.initState();
    // Tạo user hiện tại (bạn)
    _currentUser = const types.User(
      id: 'user_1',
      firstName: 'You',
    );

    // Thêm tin nhắn mẫu
    _addSampleMessages();
  }

  void _addSampleMessages() {
    final sampleMessages = [
      types.TextMessage(
        author: types.User(
            id: 'user_2',
            firstName: widget.participants
                .firstWhere((p) => p['id'] == 'user_2')['name']),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: '1',
        text: 'Chào mọi người!',
      ),
      types.TextMessage(
        author: _currentUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: '2',
        text: 'Chào bạn! Rất vui được tham gia nhóm',
      ),
    ];

    setState(() {
      _messages.addAll(sampleMessages);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final newMessage = types.TextMessage(
      author: _currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, newMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campaignTitle),
        backgroundColor: Colors.green[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _showParticipantsDialog,
          ),
        ],
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _currentUser,
        theme: DefaultChatTheme(
          primaryColor: Colors.green[600]!,
          secondaryColor: Colors.grey[200]!,
          inputBackgroundColor: Colors.grey[100]!,
        ),
      ),
    );
  }

  void _showParticipantsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thành viên nhóm'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.participants.length,
            itemBuilder: (context, index) {
              final participant = widget.participants[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Text(participant['name']![0]),
                ),
                title: Text(participant['name']!),
                subtitle: Text(participant['email']!),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
