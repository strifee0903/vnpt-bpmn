// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:intl/intl.dart';

// class RoomChatPage extends StatefulWidget {
//   final int campaignId;
//   final int userId;
//   final String username;

//   const RoomChatPage({
//     super.key,
//     required this.campaignId,
//     required this.userId,
//     required this.username,
//   });

//   @override
//   State<RoomChatPage> createState() => _RoomChatPageState();
// }

// class _RoomChatPageState extends State<RoomChatPage> {
//   late IO.Socket socket;
//   List<Map<String, dynamic>> messages = [];
//   final TextEditingController _controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _connectSocket();
//   }
// // http://10.0.2.2:3000
//   void _connectSocket() {
//     socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket.connect();

//     socket.onConnect((_) {
//       print("✅ Socket connected");
//       socket.emit('join_room', widget.campaignId);
//       socket.emit('load_messages', {
//         'campaign_id': widget.campaignId,
//         'user_id': widget.userId,
//       });
//     });

//     socket.on('load_messages_success', (data) {
//       setState(() {
//         messages = List<Map<String, dynamic>>.from(data);
//       });
//     });

//     socket.on('new_message', (data) {
//       setState(() {
//         messages.add(Map<String, dynamic>.from(data));
//       });
//     });

//     socket.on('error_message', (data) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('⚠ ${data['error']}')),
//       );
//     });

//     socket.onDisconnect((_) => print('❌ Socket disconnected'));
//   }

//   void _sendMessage() {
//     final content = _controller.text.trim();
//     if (content.isEmpty) return;

//     socket.emit('send_message', {
//       'campaign_id': widget.campaignId,
//       'sender_id': widget.userId,
//       'content': content,
//     });

//     _controller.clear();
//   }

//   String formatTime(String time) {
//     final dt = DateTime.parse(time).toLocal();
//     return DateFormat.Hm().format(dt);
//   }

//   @override
//   void dispose() {
//     socket.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat chiến dịch ${widget.campaignId}'),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Center(child: Text('@${widget.username}')),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final msg = messages[index];
//                 final isMe = msg['sender_id'] == widget.userId;
//                 return Align(
//                   alignment:
//                       isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: isMe ? Colors.blue : Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: isMe
//                           ? CrossAxisAlignment.end
//                           : CrossAxisAlignment.start,
//                       children: [
//                         if (!isMe)
//                           Text(
//                             msg['username'] ?? 'Ẩn danh',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         Text(
//                           msg['content'],
//                           style: TextStyle(
//                               color: isMe ? Colors.white : Colors.black87),
//                         ),
//                         Text(
//                           formatTime(msg['created_at']),
//                           style: TextStyle(fontSize: 10, color: Colors.black45),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: 'Nhập tin nhắn...',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: _sendMessage,
//                   icon: const Icon(Icons.send),
//                   color: Colors.blue,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// room_chat_page.dart
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:greenly_app/models/moment.dart';

import '../../moments/moments_card.dart';

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

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }
// 10.0.2.2
  void _connectSocket() {
    socket = IO.io('http://192.168.1.5:3000', <String, dynamic>{
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
    });

    socket.on('new_message', (data) {
      setState(() {
        messages.add(Map<String, dynamic>.from(data));
      });
    });

    socket.on('error_message', (data) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠ ${data['error']}')),
      );
    });

    socket.onDisconnect((_) => print('❌ Socket disconnected'));
  }

  void _sendMessage() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    socket.emit('send_message', {
      'campaign_id': widget.campaignId,
      'sender_id': widget.userId,
      'content': content,
      'type': 'text',
    });

    _controller.clear();
  }

  String formatTime(String time) {
    final dt = DateTime.parse(time).toLocal();
    return DateFormat.Hm().format(dt);
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat chiến dịch ${widget.campaignId}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('@${widget.username}')),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                        color:
                            isMe ? Colors.blue.shade100 : Colors.grey.shade200,
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                        color: isMe ? Colors.blue : Colors.grey.shade300,
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                }

            
            ),
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
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
