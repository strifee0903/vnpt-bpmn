import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenly_app/components/colors.dart';
import 'package:greenly_app/models/campaign.dart';
import 'package:greenly_app/services/campaign_service.dart';
import 'package:greenly_app/services/user_service.dart';
import 'chat_room.dart'; // import trang chat đã có

class ChatMain extends StatefulWidget {
  const ChatMain({super.key});

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
          userId = user?.u_id ?? 0; // Default to 0 if user is null
          username = user?.u_name ?? 'User_${user?.u_id}';
        });
      }
    } catch (e) {
      print('⚠️ Failed to fetch user: $e');
      if (mounted) {
        setState(() {
          userId = 0;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
    _fetchUserId();
  }

  // Future<void> _loadCampaigns() async {
  //   final data = await CampaignService().getAllCampaigns();
  //   if (mounted) {
  //     setState(() {
  //       campaigns = data;
  //       if (data.isNotEmpty) {
  //         selectedCampaignId = data.first.id;
  //       }
  //     });
  //   }
  // }
  Future<void> _loadCampaigns() async {
    final allCampaigns = await CampaignService().getAllCampaigns();
    final joinedCampaigns = <Campaign>[];

    for (final campaign in allCampaigns) {
      final isJoined =
          await CampaignService().getParticipationStatus(campaign.id);
      if (isJoined) {
        joinedCampaigns.add(campaign);
      }
    }
    setState(() {
      campaigns = joinedCampaigns;
      if (joinedCampaigns.isNotEmpty) {
        selectedCampaignId = joinedCampaigns.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.white, // Set status bar color
    //     statusBarIconBrightness: Brightness.light, // Dark icons for status bar
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(""),
      ),
      body: campaigns.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: 110,
                  child: Align(
                    alignment: Alignment.center,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      itemCount: campaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = campaigns[index];
                        final isSelected = campaign.id == selectedCampaignId;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCampaignId = campaign.id;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: isSelected ? 30 : 25,
                                  backgroundColor:
                                      isSelected ? button : Colors.grey[400],
                                  child: Text(
                                    campaign.title.characters.first,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
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
                const Divider(height: 1),
                Expanded(
                  child: selectedCampaignId == null
                      ? const Center(child: Text("Chọn một chiến dịch"))
                      : RoomChatPage(
                          campaignId: selectedCampaignId!,
                          userId: userId!,
                          username: username!,
                        ),
                ),
                const Divider(height: 10),
              ],
            ),
    );
  }
}
