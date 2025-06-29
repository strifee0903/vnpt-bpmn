import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenly_app/components/colors.dart';
import 'package:greenly_app/models/campaign.dart';
import 'package:greenly_app/services/campaign_service.dart';
import 'package:greenly_app/services/user_service.dart';
import 'chat_room.dart'; // import trang chat đã có

class ChatMain extends StatefulWidget {
  final int? selectedCampaignId; // nhận từ ngoài nếu có

  const ChatMain({super.key, this.selectedCampaignId});

  @override
  State<ChatMain> createState() => _ChatMainState();
}

class _ChatMainState extends State<ChatMain> {
  final UserService userService = UserService();
  List<Campaign> campaigns = [];
  int? selectedCampaignId;
  int? userId;
  String? username;

  Future<void> _fetchUserId() async {
    try {
      final user = await userService.getCurrentUser();
      if (mounted) {
        setState(() {
          userId = user?.u_id ?? 0;
          username = user?.u_name ?? 'User_${user?.u_id}';
        });
      }
    } catch (e) {
      print('⚠️ Failed to fetch user: $e');
      if (mounted) setState(() => userId = 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    final allCampaigns = await CampaignService().getAllCampaigns();
    final joinedCampaigns = <Campaign>[];

    for (final campaign in allCampaigns) {
      final isJoined =
          await CampaignService().getParticipationStatus(campaign.id);
      if (isJoined) joinedCampaigns.add(campaign);
    }

    setState(() {
      campaigns = joinedCampaigns;
      if (joinedCampaigns.isNotEmpty) {
        selectedCampaignId = widget.selectedCampaignId != null &&
                joinedCampaigns.any((c) => c.id == widget.selectedCampaignId)
            ? widget.selectedCampaignId
            : joinedCampaigns.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: campaigns.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 8, right: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: campaigns.length,
                            itemBuilder: (context, index) {
                              final campaign = campaigns[index];
                              final isSelected =
                                  campaign.id == selectedCampaignId;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCampaignId = campaign.id;
                                  });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: isSelected ? 24 : 20,
                                        backgroundColor: isSelected
                                            ? button
                                            : Colors.grey[400],
                                        child: Text(
                                          campaign.title.characters.first,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          campaign.title,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: selectedCampaignId == null
                      ? const Center(child: Text("Chọn một chiến dịch"))
                      : RoomChatPage(
                          campaignId: selectedCampaignId!,
                          userId: userId ?? 0,
                          username: username ?? 'Ẩn danh',
                        ),
                ),
              ],
            ),
    );
  }
}
