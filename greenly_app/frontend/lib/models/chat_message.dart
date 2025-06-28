import 'package:greenly_app/models/moment.dart';

class ChatMessage {
  final String content;
  final DateTime timestamp;
  final int senderId;
  final Moment? moment;

  ChatMessage({
    required this.content,
    required this.timestamp,
    required this.senderId,
    this.moment,
  });
}
