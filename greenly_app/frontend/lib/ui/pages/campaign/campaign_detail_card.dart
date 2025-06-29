import 'package:flutter/material.dart';
import 'package:greenly_app/components/colors.dart';
import 'package:greenly_app/models/campaign.dart';
import 'package:greenly_app/ui/pages/chat/chat_room.dart';
import 'package:intl/intl.dart';
import 'package:greenly_app/services/user_service.dart';
import 'package:provider/provider.dart';
import 'campaign_manager.dart';

String formatDate(String isoDate) {
  final date = DateTime.parse(isoDate);
  return DateFormat('dd/MM/yyyy').format(date);
}

class CampaignDetailCard extends StatefulWidget {
  final Campaign campaign;

  const CampaignDetailCard({super.key, required this.campaign});

  @override
  State<CampaignDetailCard> createState() => _CampaignDetailCardState();
}

class _CampaignDetailCardState extends State<CampaignDetailCard> {
  final UserService userService = UserService();
  int? _currentUserId;
  String? _username;
  String? _errorMessage;
  bool _isJoined = false;

  Future<void> _fetchUserId() async {
    try {
      final user = await userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUserId = user?.u_id;
          _username = user?.u_name;
          print('✅ Current User ID: ${_currentUserId}');
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

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    final campaignManager =
        Provider.of<CampaignManager>(context, listen: false);
    campaignManager.getParticipationStatus(widget.campaign.id).then((isJoined) {
      if (mounted) {
        setState(() {
          _isJoined = isJoined;
          print(
              '🔄 Participation status for campaign ${widget.campaign.id}: $_isJoined');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.campaign.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'montserrat',
              ),
            ),
            const SizedBox(height: 12),

            // Location
            Row(
              children: [
                const Icon(Icons.place, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.campaign.location ?? 'Chưa có địa điểm',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              widget.campaign.description,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),

            // Dates
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Từ ${formatDate(widget.campaign.startDate)} '
                    'đến ${formatDate(widget.campaign.endDate)}'),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
                if (_isJoined == true)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: button,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoomChatPage(
                            campaignId: widget.campaign.id,
                            userId: _currentUserId!,
                            username: _username ?? 'Ẩn danh',
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.message, color: Colors.white),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
