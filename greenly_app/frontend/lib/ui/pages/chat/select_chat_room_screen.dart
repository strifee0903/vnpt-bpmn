import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greenly_app/models/moment.dart';
import 'package:greenly_app/services/campaign_service.dart';
import 'package:greenly_app/models/campaign.dart';
import 'package:greenly_app/ui/pages/chat/chat_main.dart';
import 'package:provider/provider.dart';
import '../../../services/moment_service.dart';
import '../../auth/auth_manager.dart';
import 'chat_room.dart';
import 'socket_manager.dart';

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
  late SocketManager socketManager;
  final joinedCampaigns = <Campaign>[];

  @override
  void initState() {
    super.initState();
    socketManager = Provider.of<SocketManager>(context, listen: false);
    _initializeSocket();
  }

  Future<List<Campaign>> getAllJoinedCampaigns() async {
    final allCampaigns = await CampaignService().getAllCampaigns();
    final joinedCampaigns = <Campaign>[];

    for (final campaign in allCampaigns) {
      final isJoined =
          await CampaignService().getParticipationStatus(campaign.id);
      if (isJoined) joinedCampaigns.add(campaign);
    }

    return joinedCampaigns;
  }

  Future<void> _initializeSocket() async {
    try {
      await socketManager.initialize();
      if (!socketManager.isConnected) {
        socketManager.reconnect();
      }
      // Listen for connection status changes
      socketManager.addListener(_handleConnectionChange);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khởi tạo socket: $e")),
        );
      }
    }
  }

  void _handleConnectionChange() {
    if (mounted) {
      setState(() {}); // Update UI when connection status changes
    }
  }

  void _shareMomentToCampaign(Campaign campaign) {
    if (!socketManager.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Chưa kết nối tới máy chủ. Vui lòng thử lại."),
        ),
      );
      return;
    }

    final authManager = Provider.of<AuthManager>(context, listen: false);
    final currentUserId = authManager.loggedInUser?.u_id ?? widget.userId;

    // Validate moment media URLs
    final momentJson = widget.moment.toJson();
    if (momentJson['media'] != null &&
        (momentJson['media'] as List).isNotEmpty) {
      final mediaList = momentJson['media'] as List;
      for (var media in mediaList) {
        final url = media['media_url']?.toString();
        final absoluteUrl = MomentService.fullImageUrl(url);
        if (url == null ||
            url.isEmpty ||
            !Uri.tryParse(absoluteUrl)!.hasAbsolutePath) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi: URL hình ảnh không hợp lệ")),
          );
          return;
        }
      }
    }

    // Prepare payload
    final payload = {
      'campaign_id': campaign.id,
      'sender_id': currentUserId,
      'type': 'moment',
      'moment': momentJson,
      'username': widget.username,
      'shared_by': currentUserId,
      'shared_by_name': widget.username,
      'original_author_id': widget.moment.user.u_id,
      'original_author_name': widget.moment.user.u_name,
    };

    // Remove existing listeners to prevent duplicates
    socketManager.socket.off('new_message');
    socketManager.socket.off('error_message');

    // Set up listeners for this specific share action
    // socketManager.socket.on('new_message', (data) {
    //   print("✅ Message sent successfully: $data");
    //   if (mounted) {
    //     // Navigate directly to RoomChatPage with the shared moment
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (_) => RoomChatPage(
    //           campaignId: campaign.id,
    //           userId: currentUserId,
    //           username: widget.username,
    //           sharedMoment: widget.moment,
    //         ),
    //       ),
    //     );
    //     // Remove listeners after navigation to prevent memory leaks
    //     socketManager.socket.off('new_message');
    //     socketManager.socket.off('error_message');
    //   }
    // });

    // In SelectChatRoomScreen.dart, modify the 'new_message' listener:
    socketManager.socket.on('new_message', (data) {
      print("✅ Message sent successfully: $data");
      if (mounted) {
        // Navigate to ChatMain with the selected campaign ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatMain(
              selectedCampaignId: campaign.id,
            ),
          ),
        );
        socketManager.socket.off('new_message');
        socketManager.socket.off('error_message');
      }
    });

    socketManager.socket.on('error_message', (data) {
      print("❌ Error sending message: ${data['error']}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${data['error']}")),
        );
        // Remove listeners after error to prevent memory leaks
        socketManager.socket.off('new_message');
        socketManager.socket.off('error_message');
      }
    });

    // Join room and send message
    socketManager.joinRoom(campaign.id);
    socketManager.sendMessage(payload);
    socketManager.loadMessages({
      'campaign_id': campaign.id,
      'user_id': currentUserId,
    });
  }

  @override
  void dispose() {
    socketManager.removeListener(_handleConnectionChange);
    socketManager.socket.off('new_message');
    socketManager.socket.off('error_message');
    super.dispose();
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
                  socketManager.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: socketManager.isConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  socketManager.isConnected ? "Đã kết nối" : "Chưa kết nối",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        socketManager.isConnected ? Colors.green : Colors.red,
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
              future: getAllJoinedCampaigns(),
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
                      onTap: socketManager.isConnected
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
