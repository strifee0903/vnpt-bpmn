import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/colors.dart';
import 'addcampaign/dynamic_flow_screen.dart';
import 'package:greenly_app/models/campaign.dart' as model;
import 'package:greenly_app/services/campaign_service.dart';
import 'campaign_detail_card.dart';
import 'campaign_manager.dart';
import 'package:intl/intl.dart';

class Campaign extends StatefulWidget {
  const Campaign({super.key});

  @override
  State<Campaign> createState() => _CampaignState();
}

String formatDate(String isoDate) {
  final date = DateTime.parse(isoDate);
  return DateFormat('dd/MM/yyyy').format(date);
}

class _CampaignState extends State<Campaign> {
  int _selectedTab = 0; // 0: Created Campaigns, 1: Joined Campaigns
  final CampaignService campaignService = CampaignService();
  List<model.Campaign> campaigns = [];
  String? _currentUserId;
  Map<int, bool> _participationStatus = {};

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _fetchCampaigns();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCampaigns();
  }

  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final authUserRaw = prefs.getString('auth_user');
    if (authUserRaw != null) {
      final decoded = jsonDecode(authUserRaw);
      if (mounted) {
        setState(() {
          _currentUserId = decoded['u_id'].toString();
          print('✅ Current User ID: $_currentUserId');
        });
      }
    }
  }

  Future<void> _fetchCampaigns() async {
    final fetchedCampaigns = await campaignService.getAllCampaigns();
    final campaignManager =
        Provider.of<CampaignManager>(context, listen: false);

    if (mounted) {
      final statusMap = <int, bool>{};

      for (final campaign in fetchedCampaigns) {
        final isJoined =
            await campaignManager.getParticipationStatus(campaign.id);
        statusMap[campaign.id] = isJoined;
      }

      setState(() {
        campaigns = fetchedCampaigns;
        _participationStatus = statusMap;
        print('👽👽👽 Fetched Campaigns: ${campaigns.map((c) => {
              'campaign_id': c.id,
              'u_id': c.user?.u_id
            })}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignManager = Provider.of<CampaignManager>(context);

    final List<Map<String, Color>> entryColors = [
      {
        'background': const Color.fromARGB(255, 255, 255, 255),
        'text': const Color.fromARGB(255, 0, 0, 0),
      },
      {
        'background': const Color.fromARGB(255, 255, 253, 253),
        'text': const Color.fromARGB(255, 0, 0, 0),
      },
    ];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Campaign',
          style: TextStyle(
            fontFamily: 'Oktah',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/pcampaign.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: _selectedTab == 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: button,
                              borderRadius: BorderRadius.circular(17.0),
                            ),
                            child: Text(
                              'Created',
                              style: TextStyle(
                                fontFamily: 'Oktah',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Created',
                            style: TextStyle(
                              fontFamily: 'Oktah',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    child: _selectedTab == 1
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: button,
                              borderRadius: BorderRadius.circular(17.0),
                            ),
                            child: Text(
                              'Joined',
                              style: TextStyle(
                                fontFamily: 'Oktah',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Joined',
                            style: TextStyle(
                              fontFamily: 'Oktah',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  final campaign = campaigns[index];
                  final colors = entryColors[index % entryColors.length];
                  final isCreator = _currentUserId != null &&
                      campaign.user?.u_id.toString() == _currentUserId;

                  return FutureBuilder<bool>(
                    future: campaignManager.getParticipationStatus(campaign.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final isJoined =
                          _participationStatus[campaign.id] ?? false;

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Center(
                              child: CampaignDetailCard(campaign: campaign),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: colors['background'],
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 1, 15, 1)
                                    .withAlpha((0.1 * 255).toInt()),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        campaign.title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Oktah',
                                          fontWeight: FontWeight.w700,
                                          color: colors['text'],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        campaign.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Oktah',
                                          fontWeight: FontWeight.w500,
                                          color:
                                              colors['text']!.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        campaign.location ?? 'No location',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Oktah',
                                          fontWeight: FontWeight.w500,
                                          color:
                                              colors['text']!.withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'From ${formatDate(campaign.startDate)} to ${formatDate(campaign.endDate)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Oktah',
                                          fontWeight: FontWeight.w400,
                                          color:
                                              colors['text']!.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    TextButton(
                                      onPressed: isCreator
                                          ? null // Disable button for creator
                                          : () async {
                                              final success = isJoined
                                                  ? await campaignManager
                                                      .leaveCampaign(
                                                          campaign.id)
                                                  : await campaignManager
                                                      .joinCampaign(
                                                          campaign.id);
                                              if (success) {
                                                final newStatus =
                                                    isJoined ? false : true;
                                                setState(() {
                                                  _participationStatus[
                                                      campaign.id] = newStatus;
                                                });
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      isJoined
                                                          ? 'Failed to leave campaign'
                                                          : 'Failed to join campaign',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                      style: TextButton.styleFrom(
                                        backgroundColor: isCreator
                                            ? Colors.grey // Grey for Hosting
                                            : isJoined
                                                ? Colors.red
                                                : button,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(
                                        isCreator
                                            ? 'Hosting'
                                            : (isJoined ? 'Leave' : 'Join'),
                                        style: const TextStyle(
                                          fontFamily: 'Oktah',
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: IconButton(
                                        icon: const Icon(Icons.chevron_right,
                                            size: 24),
                                        color: colors['text']!.withOpacity(0.7),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => Center(
                                              child: CampaignDetailCard(
                                                  campaign: campaign),
                                            ),
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (_) => CampaignManager(),
                  child: const DynamicFlowPage(),
                ),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            backgroundColor: button,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add,
                size: 20,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              const SizedBox(width: 4),
              const Text(
                'Create Campaign',
                style: TextStyle(
                  fontFamily: 'Oktah',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
