import 'package:flutter/material.dart';
import 'package:greenly_app/ui/pages/campaign/campaign_detail_card.dart';
import 'package:provider/provider.dart';
import '../../../components/colors.dart'; // Import colors.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'addcampaign/dynamic_flow_screen.dart'; // Import
import 'package:greenly_app/models/campaign.dart' as model;
import 'package:greenly_app/services/campaign_service.dart';
import 'campaign_manager.dart'; // Import CampaignManager
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
  // Trạng thái tab được chọn
  int _selectedTab = 0; // 0: Created Campaigns, 1: Joined Campaigns
  final CampaignService campaignService = CampaignService();
  List<model.Campaign> campaigns = [];
  @override
  void initState() {
    super.initState();
    // Khởi tạo CampaignManager nếu cần
    campaignService.getAllCampaigns().then((fetchedCampaigns) {
      setState(() {
        campaigns = fetchedCampaigns;
      });
    }).catchError((error) {
      // Xử lý lỗi nếu có
      print('Error fetching campaigns: $error');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Được gọi lại khi widget được hiển thị lại sau khi quay lại
    campaignService.getAllCampaigns().then((fetchedCampaigns) {
      setState(() {
        campaigns = fetchedCampaigns;
      });
    }).catchError((error) {
      // Xử lý lỗi nếu có
      print('Error fetching campaigns: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sample list of campaign entries

    // List of color pairs for each campaign entry (background and text color)
    final List<Map<String, Color>> entryColors = [
      {
        'background': const Color.fromARGB(255, 255, 255, 255), // Light green
        'text': const Color.fromARGB(255, 0, 0, 0), // Dark green
      },
      {
        'background': const Color.fromARGB(255, 255, 253, 253), // Lighter green
        'text': const Color.fromARGB(255, 0, 0, 0), // Medium green
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
          crossAxisAlignment:
              CrossAxisAlignment.start, // Đảm bảo căn trái toàn bộ cột
          children: [
            // Add Campaign Section (Image only)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/pcampaign.jpg', // Thay bằng đường dẫn hình ảnh thực tế
                    fit: BoxFit
                        .contain, // Sử dụng BoxFit.contain để giữ tỷ lệ gốc
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0), // Khoảng cách giữa hình ảnh và filter

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 8.0), // Kích thước cố định
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: _selectedTab == 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35.0,
                                vertical: 10.0), // Thêm padding bên trong
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
                      horizontal: 15.0, vertical: 8.0), // Kích thước cố định
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    child: _selectedTab == 1
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35.0,
                                vertical: 10.0), // Thêm padding bên trong
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      color: colors['text']!.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    campaign.location ?? 'No location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Oktah',
                                      fontWeight: FontWeight.w500,
                                      color: colors['text']!.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'From ${formatDate(campaign.startDate)} to ${formatDate(campaign.endDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Oktah',
                                      fontWeight: FontWeight.w400,
                                      color: colors['text']!.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: IconButton(
                                icon: const Icon(Icons.chevron_right, size: 24),
                                color: colors['text']!.withOpacity(0.7),
                                onPressed: () {
                                  // TODO: Xem chi tiết campaign
                                  // Navigator.push(...);
                                },
                                padding: EdgeInsets.zero,
                              ),
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
      // Nút "Thêm Campaign" float ở góc dưới bên phải
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                      create: (_) => CampaignManager(),
                      child: const DynamicFlowPage())),
            ); // Điều hướng sang Step1
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
              const SizedBox(width: 4), // Khoảng cách giữa icon và text
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
