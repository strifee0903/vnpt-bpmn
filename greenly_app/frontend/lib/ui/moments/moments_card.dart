import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_manager.dart';
import '../pages/profile/profile_screen.dart';
import '../pages/profile/otherUserProfile.dart';

class MomentCard extends StatelessWidget {
  final String username;
  final String avatar;
  final String status;
  final List<String>? images;
  final String location;
  final double? latitude;
  final double? longitude;
  final String time;
  final String type;
  final String category;
  final int userId;
  final void Function(int userId, String username, String avatarUrl)? onUserTap;

  const MomentCard({
    super.key,
    required this.username,
    required this.avatar,
    required this.status,
    this.images,
    required this.location,
    this.latitude,
    this.longitude,
    required this.time,
    required this.type,
    required this.category,
    required this.userId,
    this.onUserTap,
  });

  void _handleUserTap(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final currentUser = authManager.loggedInUser;

    if (currentUser != null && currentUser.u_id == userId) {
      // Navigate to own profile
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ),
      );
    } else {
      // Navigate to other user's profile
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtherUserProfileScreen(
            userId: userId,
            username: username,
            avatarUrl: avatar,
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
                          avatar,
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
                    username,
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
              const Icon(Icons.more_vert),
            ],
          ),
        ),

        // Status
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            status,
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
        if (images != null && images!.isNotEmpty)
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: images!.length,
              itemBuilder: (context, index) {
                final image = images![index];
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
        if (images != null && images!.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images!.length, (index) {
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
                      time,
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
                      '${latitude?.toStringAsFixed(4)}, ${longitude?.toStringAsFixed(4)}',
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
                      location,
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
                  getMomentTypeIcon(type),
                  const SizedBox(width: 4),
                  Text(type, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  getCategoryIcon(category),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      category,
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
