// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';

// class GroupChatScreen extends StatefulWidget {
//   final String campaignTitle;
//   final List<types.User> participants;

//   const GroupChatScreen({
//     super.key,
//     required this.campaignTitle,
//     required this.participants,
//   });

//   @override
//   State<GroupChatScreen> createState() => _GroupChatScreenState();
// }

// class _GroupChatScreenState extends State<GroupChatScreen> {
//   final List<types.Message> _messages = [];
//   final types.User _currentUser =
//       const types.User(id: 'user_1', firstName: 'Bạn');

//   void _handleSendPressed(types.PartialText message) {
//     final newMessage = types.TextMessage(
//       author: _currentUser,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//       id: const Uuid().v4(),
//       text: message.text,
//     );

//     setState(() {
//       _messages.insert(0, newMessage);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.campaignTitle),
//         backgroundColor: Colors.green[600],
//       ),
//       body: Chat(
//         messages: _messages,
//         onSendPressed: _handleSendPressed,
//         user: _currentUser,
//         showUserAvatars: true,
//         showUserNames: true,
//       ),
//     );
//   }
// }
