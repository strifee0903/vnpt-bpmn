import 'package:flutter/material.dart';
import 'package:greenly_app/models/campaign.dart';
import 'package:intl/intl.dart';

String formatDate(String isoDate) {
  final date = DateTime.parse(isoDate);
  return DateFormat('dd/MM/yyyy').format(date);
}

class CampaignDetailCard extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailCard({super.key, required this.campaign});

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
              campaign.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Oktah',
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
                    campaign.location ?? 'Chưa có địa điểm',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              campaign.description,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),

            // Dates
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Từ ${formatDate(campaign.startDate)} '
                    'đến ${formatDate(campaign.endDate)}'),
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
                ElevatedButton(
                  onPressed: () {
                    // TODO: Xử lý nút Tham gia hoặc Chỉnh sửa
                  },
                  child: const Text('Tham gia'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
