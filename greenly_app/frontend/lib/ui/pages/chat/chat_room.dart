import 'package:flutter/material.dart';
import 'package:greenly_app/components/colors.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:greenly_app/models/moment.dart';

class RoomChatPage extends StatefulWidget {
  final int campaignId;
  final int userId;
  final String username;
  final Moment? sharedMoment;

  const RoomChatPage({
    super.key,
    required this.campaignId,
    required this.userId,
    required this.username,
    this.sharedMoment,
  });

  @override
  State<RoomChatPage> createState() => _RoomChatPageState();
}

class _RoomChatPageState extends State<RoomChatPage> {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = true;
  bool _hasNewMessage = false;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final atBottom = (maxScroll - currentScroll).abs() < 50;
      if (_isAtBottom != atBottom) {
        setState(() {
          _isAtBottom = atBottom;
          if (_isAtBottom) _hasNewMessage = false;
        });
      }
    });
    _scrollToBottom();
  }

  @override
  void didUpdateWidget(covariant RoomChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.campaignId != oldWidget.campaignId) {
      // Rời phòng cũ
      socket.emit('leave_room', oldWidget.campaignId);
      // Clear tin nhắn cũ
      setState(() {
        messages.clear();
      });
      // Tham gia phòng mới
      socket.emit('join_room', widget.campaignId);
      socket.emit('load_messages', {
        'campaign_id': widget.campaignId,
        'user_id': widget.userId,
      });
      if (widget.sharedMoment != null) {
        socket.emit('send_message', {
          'campaign_id': widget.campaignId,
          'sender_id': widget.userId,
          'type': 'moment',
          'moment': widget.sharedMoment!.toJson(),
        });
      }
    }
  }

// 10.0.2.2
  void _connectSocket() {
    socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      socket.emit('join_room', widget.campaignId);

      socket.emit('load_messages', {
        'campaign_id': widget.campaignId,
        'user_id': widget.userId,
      });

      if (widget.sharedMoment != null) {
        socket.emit('send_message', {
          'campaign_id': widget.campaignId,
          'sender_id': widget.userId,
          'type': 'moment',
          'moment': widget.sharedMoment!.toJson(),
        });
      }
    });

    socket.on('load_messages_success', (data) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(data);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });

    socket.on('new_message', (data) {
      setState(() {
        messages.add(Map<String, dynamic>.from(data));
        // _hasNewMessage = true;

        if (_isAtBottom) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else {
          _hasNewMessage = true;
        }
      });
    });

    socket.on('error_message', (data) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠ ${data['error']}')),
      );
    });

    socket.onDisconnect((_) => print('❌ Socket disconnected'));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    socket.emit('send_message', {
      'campaign_id': widget.campaignId,
      'sender_id': widget.userId,
      'content': content,
      'type': 'text',
      'username': widget.username,
    });

    _controller.clear();
  }

  String formatTime(String time) {
    final dt = DateTime.parse(time).toLocal();
    return DateFormat.Hm().format(dt);
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Chat chiến dịch ${widget.campaignId}'),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 12),
      //       child: Center(child: Text('@${widget.username}')),
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.campaign, color: button, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chat chiến dịch ${widget.campaignId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: button,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    widget.username.isNotEmpty
                        ? widget.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: button),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '@${widget.username}',
                  style: const TextStyle(
                    color: button,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(children: [
              ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: false,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == widget.userId;
                    final type = msg['type'] ?? 'text';

                    Widget messageWidget;

                    if (type == 'moment' && msg['moment'] != null) {
                      final moment = msg['moment'];
                      messageWidget = Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                msg['username'] ?? 'Ẩn danh',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            Text(
                              '[Moment] ${moment['moment_content'] ?? '(Không có nội dung)'}',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            if (moment['media'] != null &&
                                moment['media'].isNotEmpty)
                              Image.network(
                                moment['media'][0]['media_url'],
                                height: 150,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            Text(
                              formatTime(msg['created_at']),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black45),
                            ),
                          ],
                        ),
                      );
                    } else {
                      messageWidget = Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? button : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                msg['username'] ?? 'Ẩn danh',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            Text(
                              msg['content'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              formatTime(msg['created_at']),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black45),
                            ),
                          ],
                        ),
                      );
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: messageWidget,
                      ),
                    );
                  }),
              if (_hasNewMessage)
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });
                      setState(() {
                        _hasNewMessage = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: button,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Tin nhắn mới',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    _sendMessage();
                  },
                  icon: const Icon(Icons.send),
                  color: button,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
