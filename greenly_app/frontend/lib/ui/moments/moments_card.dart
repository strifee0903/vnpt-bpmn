import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/moment.dart';
import '../../services/moment_service.dart';
import '../../shared/main_layout.dart';
import '../auth/auth_manager.dart';
import '../pages/profile/otherUserProfile.dart';
import 'edit_moment.dart';

class MomentCard extends StatelessWidget {
  final Moment moment;
  final void Function(int userId, String username, String avatarUrl)? onUserTap;
  final VoidCallback? refreshFeed; // Add callback for refreshing feed

  const MomentCard({
    super.key,
    required this.moment,
    this.onUserTap,
    this.refreshFeed,
  });

  void _handleUserTap(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final currentUser = authManager.loggedInUser;

    if (currentUser != null && currentUser.u_id == moment.user.u_id) {
      // Navigate to own profile with Profile tab selected
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MainLayout(initialIndex: 3), // Set index to 3 (Profile)
        ),
      );
    } else {
      // Navigate to other user's profile
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtherUserProfileScreen(
            userId: moment.user.u_id,
            username: moment.user.u_name,
            avatarUrl: moment.user.u_avt ?? '',
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + username
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _handleUserTap(context),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: Image.network(
                          MomentService.fullImageUrl(
                              moment.user.u_avt), 
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleUserTap(context),
                  child: Text(
                    moment.user.u_name,
                    style: const TextStyle(
                      fontFamily: 'Oktah',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditMomentScreen(moment: moment),
                        ),
                      );
                      if (result == 'deleted' || result is Moment) {
                        refreshFeed
                            ?.call(); // Trigger refresh after edit/delete
                      }
                      break;
                    case 'delete':
                      final momentService =
                          Provider.of<MomentService>(context, listen: false);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Moment'),
                          content: const Text(
                              'Are you sure you want to delete this moment?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await momentService.deleteMoment(moment.id);
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                  refreshFeed?.call();
                                } catch (e) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to delete moment: $e')),
                                  );
                                }
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      break;
                    case 'hide':
                      // TODO: Implement hide functionality
                      break;
                    case 'report':
                      // TODO: Implement report functionality
                      break;
                  }
                },
                itemBuilder: (context) {
                  final currentUser =
                      Provider.of<AuthManager>(context, listen: false)
                          .loggedInUser;
                  final isOwner = currentUser != null &&
                      currentUser.u_id == moment.user.u_id;

                  if (isOwner) {
                    return [
                      const PopupMenuItem(
                          value: 'edit', child: Text('Sửa bài viết')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Xoá bài viết')),
                    ];
                  } else {
                    return [
                      const PopupMenuItem(
                          value: 'hide', child: Text('Ẩn bài viết')),
                      const PopupMenuItem(
                          value: 'report', child: Text('Báo cáo bài viết')),
                    ];
                  }
                },
              ),

            ],
          ),
        ),

        // Status
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            moment.content,
            style: const TextStyle(
              fontFamily: 'Oktah',
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
        const SizedBox(height: 10),

        // Image carousel
        if (moment.media.isNotEmpty)
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: moment.media.length,
              itemBuilder: (context, index) {
                final image =
                    MomentService.fullImageUrl(moment.media[index].media_url);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                );
              },
            ),
          ),

        // Image indicator
        if (moment.media.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(moment.media.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),

        // Info: time, location, coordinates, type, category
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time & Coordinates
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(moment.createdAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${moment.latitude?.toStringAsFixed(4) ?? 'N/A'}, ${moment.longitude?.toStringAsFixed(4) ?? 'N/A'}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.travel_explore,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      moment.address,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Type & Category
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getMomentTypeIcon(moment.type),
                  const SizedBox(width: 4),
                  Text(moment.type, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  getCategoryIcon(moment.category.category_name),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      moment.category.category_name,
                      style: const TextStyle(fontSize: 14),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

Icon getMomentTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'event':
      return const Icon(Icons.event, size: 18, color: Colors.blueAccent);
    case 'diary':
      return const Icon(Icons.book,
          size: 18, color: Color.fromARGB(255, 48, 39, 176));
    case 'report':
      return const Icon(Icons.list_alt_rounded,
          size: 18, color: Color.fromARGB(255, 163, 22, 22));
    default:
      return const Icon(Icons.help_outline, size: 18, color: Colors.grey);
  }
}

Icon getCategoryIcon(String category) {
  final map = {
    'Nhặt rác': Icons.cleaning_services,
    'Trồng cây': Icons.park,
    'Tái chế': Icons.loop,
    'Tiết kiệm điện': Icons.lightbulb,
    'Không dùng nhựa': Icons.block,
    'Chia sẻ kiến thức môi trường': Icons.school,
    'Đi xe đạp': Icons.directions_bike,
    'Sử dụng năng lượng mặt trời': Icons.solar_power,
    'Sống xanh': Icons.eco,
    'Làm sạch bãi biển': Icons.beach_access,
  };

  return Icon(map[category] ?? Icons.category, size: 18, color: Colors.green);
}
