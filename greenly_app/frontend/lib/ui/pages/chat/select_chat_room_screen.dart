import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greenly_app/models/moment.dart';
import 'package:greenly_app/services/campaign_service.dart';
import 'package:greenly_app/models/campaign.dart';
import 'package:greenly_app/ui/pages/chat/chat_main.dart';
import 'package:greenly_app/ui/pages/chat/chat_manager.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../services/moment_service.dart';
import '../../auth/auth_manager.dart';
import 'chat_room.dart';
import 'socket_config.dart';

class SelectChatRoomScreen extends StatefulWidget {
  final Moment moment;
  final int userId;
  final String username;

  const SelectChatRoomScreen({
    super.key,
    required this.moment,
    required this.userId,
    required this.username,
  });

  @override
  State<SelectChatRoomScreen> createState() => _SelectChatRoomScreenState();
}

class _SelectChatRoomScreenState extends State<SelectChatRoomScreen> {
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    final socketManager = SocketManager();
    final socket = socketManager.socket;
    socket.onConnect((_) {
      print("🟢 Socket connected successfully");
      setState(() {
        _isConnected = true;
      });
    });
    setState(() {
      _isConnected = true;
    });
    socket.onConnectError((data) {
      print("❌ Socket connection error: $data");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể kết nối tới máy chủ chat: $data")),
        );
      }
    });
  }

  void _shareMomentToCampaign(Campaign campaign) {
    final socketManager = SocketManager();
    final socket = socketManager.socket;
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Chưa kết nối tới máy chủ. Vui lòng thử lại.")),
      );
      return;
    }

    final authManager = Provider.of<AuthManager>(context, listen: false);
    final currentUserId = authManager.loggedInUser?.u_id ?? widget.userId;

    final momentJson = widget.moment.toJson();
    if (momentJson['media'] != null &&
        (momentJson['media'] as List).isNotEmpty) {
      final mediaList = momentJson['media'] as List;
      for (var media in mediaList) {
        final url = media['media_url']?.toString();
        // ignore: unused_local_variable
        final absoluteUrl = MomentService.fullImageUrl(url);
        if (url == null || url.isEmpty || !Uri.tryParse(url)!.hasAbsolutePath) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi: URL hình ảnh không hợp lệ")),
          );
          return;
        }
      }
    }

    final momentData = widget.moment.toJson();
    final payload = {
      'campaign_id': campaign.id,
      'sender_id': currentUserId,
      'type': 'moment',
      'moment': momentData,
      'username': widget.username,
      'shared_by': currentUserId,
      'shared_by_name': widget.username,
      'original_author_id': widget.moment.user.u_id,
      'original_author_name': widget.moment.user.u_name,
    };

    print("📤 Sending moment share payload:");
    print(jsonEncode(payload));

    socket.off('new_message');
    socket.off('error_message');

    bool messageSent = false;
    socket.on('load_messages_success', (data) {
      print("✅ Tin nhắn đã load thành công: $data");
      if (!messageSent && mounted) {
        messageSent = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatMain(
              selectedCampaignId: campaign.id,
            ),
          ),
        );
      }
    });

    socket.emit('join_room', campaign.id);
    socket.emit('load_messages', {
      'campaign_id': campaign.id,
      'user_id': currentUserId,
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      socket.emit('send_message', payload);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chia sẻ đến chiến dịch"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? "Đã kết nối" : "Chưa kết nối",
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bài viết sẽ được chia sẻ:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.moment.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.moment.media.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 60,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        MomentService.fullImageUrl(
                            widget.moment.media.first.media_url),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ Preview image load error: $error');
                          print(
                              '❌ Failed URL: ${widget.moment.media.first.media_url}');
                          return const Icon(Icons.broken_image);
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  "Tác giả: ${widget.moment.user.u_name}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Campaign>>(
              future: CampaignService().getAllCampaigns(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Bạn chưa tham gia chiến dịch nào."),
                  );
                }

                final campaigns = snapshot.data!;
                return ListView.builder(
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = campaigns[index];
                    return ListTile(
                      leading: const Icon(Icons.campaign),
                      title: Text(campaign.title),
                      subtitle: Text("ID: ${campaign.id}"),
                      trailing: const Icon(Icons.send),
                      onTap: _isConnected
                          ? () => _shareMomentToCampaign(campaign)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
