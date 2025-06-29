import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/colors.dart';
import 'addcampaign/dynamic_flow_screen.dart';
import 'package:greenly_app/models/campaign.dart' as model;
import 'package:greenly_app/services/campaign_service.dart';
import 'package:greenly_app/services/user_service.dart';
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
  final UserService userService = UserService();
  List<model.Campaign> campaigns = [];
  String? _currentUserId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _fetchCampaigns();
  }

  Future<void> _fetchUserId() async {
    try {
      final user = await userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUserId = user?.u_id.toString();
          print('✅ Current User ID: $_currentUserId');
        });
      }
    } catch (e) {
      print('⚠️ Failed to fetch user: $e');
      if (mounted) {
        setState(() {
          _currentUserId = null;
          _errorMessage = 'Failed to load user data. Please log in again.';
        });
      }
    }
  }

  Future<void> _fetchCampaigns() async {
    try {
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
          campaigns = _selectedTab == 0
              ? fetchedCampaigns // Show all campaigns in "Created" tab
              : fetchedCampaigns.where((c) => statusMap[c.id] == true).toList();
          campaignManager.updateParticipationStatus(statusMap);
          _errorMessage = campaigns.isEmpty && _selectedTab == 0
              ? 'You have not created any campaigns.'
              : campaigns.isEmpty && _selectedTab == 1
                  ? 'You have not joined any campaigns.'
                  : null;
          print('👽👽👽 Fetched Campaigns: ${campaigns.map((c) => {
                'campaign_id': c.id,
                'u_id': c.user?.u_id,
                'is_joined': statusMap[c.id]
              })}');
        });
      }
    } catch (e) {
      print('⚠️ Failed to fetch campaigns: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load campaigns: $e';
        });
      }
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Set status bar color
        statusBarIconBrightness: Brightness.light, // Dark icons for status bar
      ),
    );
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Campaign',
          style: TextStyle(
            fontFamily: 'montserrat',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
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
                        _fetchCampaigns();
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
                                fontFamily: 'montserrat',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Created',
                            style: TextStyle(
                              fontFamily: 'montserrat',
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
                        _fetchCampaigns();
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
                                fontFamily: 'montserrat',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Joined',
                            style: TextStyle(
                              fontFamily: 'montserrat',
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
              child: campaigns.isEmpty
                  ? Center(
                    child: CircularProgressIndicator())
                  // Center(
                  //     child: Text(_errorMessage ?? 'No campaigns available'))
                  //           const Center(
                  //   child: CircularProgressIndicator(),
                  // )
                  : ListView.builder(
                      itemCount: campaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = campaigns[index];
                        final colors = entryColors[index % entryColors.length];
                        final isCreator = _currentUserId != null &&
                            campaign.user?.u_id.toString() == _currentUserId;
                        final campaignManager =
                            Provider.of<CampaignManager>(context, listen: true);
                        final isJoined =
                            campaignManager.participationStatus[campaign.id] ??
                                false;

                        // // Double-check participation status with backend if needed
                        // void verifyParticipationStatus() async {
                        //   final updatedIsJoined = await campaignManager
                        //       .getParticipationStatus(campaign.id);
                        //   if (updatedIsJoined != isJoined) {
                        //     setState(() {
                        //       _fetchCampaigns(); // Refresh campaigns if status mismatches
                        //     });
                        //   }
                        // }

                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                        //   if (isJoined)
                        //     verifyParticipationStatus(); // Verify if "Leave" is shown
                        // });

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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            fontFamily: 'montserrat',
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
                                            fontFamily: 'montserrat',
                                            fontWeight: FontWeight.w500,
                                            color: colors['text']!
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          campaign.location ?? 'No location',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'montserrat',
                                            fontWeight: FontWeight.w500,
                                            color: colors['text']!
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'From ${formatDate(campaign.startDate)} to ${formatDate(campaign.endDate)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'montserrat',
                                            fontWeight: FontWeight.w400,
                                            color: colors['text']!
                                                .withOpacity(0.5),
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
                                                  setState(() {
                                                    _fetchCampaigns(); // Reload campaigns
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
                                              ? Colors.grey
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
                                            fontFamily: 'montserrat',
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: IconButton(
                                          icon: const Icon(Icons.chevron_right,
                                              size: 24),
                                          color:
                                              colors['text']!.withOpacity(0.7),
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
                  fontFamily: 'montserrat',
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
