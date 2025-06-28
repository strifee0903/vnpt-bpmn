import 'package:greenly_app/models/moment.dart';
import '../../../models/chat_message.dart';

class ChatRoomService {
  static final Map<int, List<ChatMessage>> _campaignMessages = {};

  static Future<void> sendMomentToCampaign(
      int campaignId, Moment moment) async {
    _campaignMessages.putIfAbsent(campaignId, () => []);
    _campaignMessages[campaignId]!.add(ChatMessage(
      content: '[Moment được chia sẻ]',
      senderId: 0,
      timestamp: DateTime.now(),
      moment: moment,
    ));
  }

  static Future<List<ChatMessage>> getMessagesForCampaign(
      int campaignId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _campaignMessages[campaignId] ?? [];
  }
}
