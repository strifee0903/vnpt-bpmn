// select_chat_room_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greenly_app/models/moment.dart';
import 'package:greenly_app/services/campaign_service.dart';
import 'package:greenly_app/models/campaign.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'chat_room.dart';

class SelectChatRoomScreen extends StatelessWidget {
  final Moment moment;
  final int userId;
  final String username;

  const SelectChatRoomScreen({
    super.key,
    required this.moment,
    required this.userId,
    required this.username,
  });

  void _shareMomentToCampaign(BuildContext context, Campaign campaign) {
    final socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      socket.emit('join_room', campaign.id);
      socket.emit('send_message', {
        'campaign_id': campaign.id,
        'sender_id': userId,
        'type': 'moment',
        'content': jsonEncode(moment.toJson()), // JSON string
      });

      // 👇 Sau khi gửi xong thì chuyển luôn tới RoomChatPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoomChatPage(
            campaignId: campaign.id,
            userId: userId,
            username: username,
          ),
        ),
      );
    });


    socket.onConnectError((data) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể kết nối tới máy chủ chat.")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chia sẻ đến chiến dịch")),
      body: FutureBuilder<List<Campaign>>(
        future: CampaignService().getAllCampaigns(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("Bạn chưa tham gia chiến dịch nào."));
          }

          final campaigns = snapshot.data!;
          return ListView.builder(
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              return ListTile(
                title: Text(campaign.title),
                trailing: const Icon(Icons.send),
                onTap: () => _shareMomentToCampaign(context, campaign),
              );
            },
          );
        },
      ),
    );
  }
}
