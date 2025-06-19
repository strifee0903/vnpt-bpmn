import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_manager.dart';
import '../../../components/colors.dart'; // Import your colors
import '../../moments/moments_card.dart'; // Import MomentCard
import '../../moments/add_moment_place.dart'; // Import AddMomentPlace

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Danh sách mẫu cho các bài post (thay bằng dữ liệu thực tế nếu có)
  final List<Map<String, dynamic>> samplePosts = const [
    {
      'username': 'Mahmud Nik',
      'avatar': 'https://via.placeholder.com/40',
      'status': 'Enjoying a great day at the park!',
      'images': [
        'https://via.placeholder.com/300',
        'https://via.placeholder.com/300'
      ],
      'location': 'Park Street, District 1, Ho Chi Minh',
      'latitude': 10.7769,
      'longitude': 106.7009,
      'time': '2025-06-19 14:00',
      'type': 'Diary',
      'category': 'Tree Planting',
    },
    {
      'username': 'Mahmud Nik',
      'avatar': 'https://via.placeholder.com/40',
      'status': 'Recycling event today!',
      'images': ['https://via.placeholder.com/300'],
      'location': 'Green Road, District 3, Ho Chi Minh',
      'latitude': 10.7800,
      'longitude': 106.6950,
      'time': '2025-06-19 15:00',
      'type': 'Event',
      'category': 'Recycling',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    final user = authManager.loggedInUser;

    // return Scaffold(
    //   body: SafeArea(
    //     child: Container(
    //       // Thêm Container để áp dụng màu nền background cho toàn bộ khu vực
    //       color: background, // Đảm bảo toàn bộ nền là background
    //       child: SingleChildScrollView(
    //         child: Column(
    //           children: [
    //             // Header với tiêu đề và icon bánh răng
    //             Container(
    //               padding: const EdgeInsets.symmetric(
    //                   vertical: 16.0, horizontal: 16.0),
    //               color: button,
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   SizedBox(width: 49.0),
    //                   const Expanded(
    //                     child: Text(
    //                       'Profile',
    //                       textAlign: TextAlign.center,
    //                       style: TextStyle(
    //                         fontSize: 25,
    //                         fontFamily: 'Oktah',
    //                         fontWeight: FontWeight.w900,
    //                         color: Colors.white,
    //                       ),
    //                     ),
    //                   ),
    //                   IconButton(
    //                     icon: const Icon(Icons.settings, color: Colors.white),
    //                     onPressed: () {
    //                       // Xử lý Edit Profile
    //                     },
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             // Phần thông tin cá nhân (avatar và email) trong container bo tròn
    //             Container(
    //               width: double.infinity,
    //               padding: const EdgeInsets.all(20.0),
    //               decoration: const BoxDecoration(
    //                 color: button,
    //                 borderRadius: BorderRadius.vertical(
    //                   bottom: Radius.circular(25.0),
    //                 ),
    //               ),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   CircleAvatar(
    //                     radius: 55,
    //                     backgroundImage:
    //                         const AssetImage('assets/images/blankava.png'),
    //                     backgroundColor: button,
    //                     child: const Stack(
    //                       children: [
    //                         Positioned(
    //                           bottom: 0,
    //                           right: 0,
    //                           child: CircleAvatar(
    //                             radius: 12,
    //                             backgroundColor: Colors.white,
    //                             child: Icon(Icons.add,
    //                                 size: 14, color: Color(0xFFADD8E6)),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   const SizedBox(height: 20.0),
    //                   // Hiển thị tên người dùng
    //                   Text(
    //                     'Unknown User', // Tên người dùng từ AuthManager
    //                     style: const TextStyle(
    //                       fontSize: 21,
    //                       fontFamily: 'Oktah',
    //                       fontWeight: FontWeight.w700,
    //                       color: Colors.white,
    //                     ),
    //                     textAlign: TextAlign.center,
    //                   ),
    //                   const SizedBox(
    //                       height: 3.0), // Khoảng cách giữa tên và email
    //                   // Hiển thị email
    //                   RichText(
    //                     text: TextSpan(
    //                       children: [
    //                         const TextSpan(
    //                           text: 'Email: ',
    //                           style: TextStyle(
    //                             fontSize: 15,
    //                             fontFamily: 'Oktah',
    //                             fontWeight: FontWeight.w500,
    //                             color: Colors.white70,
    //                           ),
    //                         ),
    //                         TextSpan(
    //                           text: '${user?.u_email ?? ''}',
    //                           style: const TextStyle(
    //                             fontSize: 16,
    //                             fontFamily: 'Oktah',
    //                             fontWeight: FontWeight.w500,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     textAlign: TextAlign.center,
    //                   ),
    //                   const SizedBox(height: 16.0),
    //                 ],
    //               ),
    //             ),
    //             // Widget AddMomentPlace
    //             const SizedBox(height: 10.0),
    //             const AddMomentPlace(),
    //             // Phần hiển thị các bài post
    //             Container(
    //               color:
    //                   background, // Đảm bảo nền của danh sách bài post là background
    //               child: ListView.builder(
    //                 shrinkWrap: true,
    //                 physics: const NeverScrollableScrollPhysics(),
    //                 padding: const EdgeInsets.all(8.0),
    //                 itemCount: samplePosts.length,
    //                 itemBuilder: (context, index) {
    //                   final post = samplePosts[index];
    //                   return MomentCard(
    //                     username: post['username'],
    //                     avatar: post['avatar'],
    //                     status: post['status'],
    //                     images: post['images'] != null
    //                         ? List<String>.from(post['images'])
    //                         : null,
    //                     location: post['location'],
    //                     latitude: post['latitude'],
    //                     longitude: post['longitude'],
    //                     time: post['time'],
    //                     type: post['type'],
    //                     category: post['category'],
    //                   );
    //                 },
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  
  return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: button,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'Oktah',
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              authManager.logout(); // ✅ Đăng xuất
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // Mở màn hình cài đặt hoặc sửa profile
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          color: background,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🧼 Xoá container header cũ đi nếu đã dùng AppBar
                // ✅ Giữ phần avatar + thông tin người dùng
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    color: button,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(25.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage:
                            const AssetImage('assets/images/blankava.png'),
                        backgroundColor: button,
                        child: const Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.add,
                                    size: 14, color: Color(0xFFADD8E6)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        user?.u_name ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 21,
                          fontFamily: 'Oktah',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3.0),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Email: ',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Oktah',
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                            TextSpan(
                              text: '${user?.u_email ?? ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Oktah',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                const AddMomentPlace(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8.0),
                  itemCount: samplePosts.length,
                  itemBuilder: (context, index) {
                    final post = samplePosts[index];
                    return MomentCard(
                      username: post['username'],
                      avatar: post['avatar'],
                      status: post['status'],
                      images: post['images'] != null
                          ? List<String>.from(post['images'])
                          : null,
                      location: post['location'],
                      latitude: post['latitude'],
                      longitude: post['longitude'],
                      time: post['time'],
                      type: post['type'],
                      category: post['category'],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }

}
