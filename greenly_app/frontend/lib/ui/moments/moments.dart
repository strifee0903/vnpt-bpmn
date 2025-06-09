import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../components/colors.dart'; // Import colors.dart
import '../../shared/appbar.dart'; // Import CustomBottomAppBar

class MomentsPage extends StatefulWidget {
  const MomentsPage({super.key});

  @override
  _MomentsPageState createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
  int _currentIndex = 1; // Đặt mặc định là 1 vì đây là trang Moments (Post)

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Cập nhật tab hiện tại
    });
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách bài viết giả lập
    final List<Map<String, dynamic>> posts = [
      {
        'username': 'john doe',
        'avatar': 'assets/images/mydiary.png',
        'status': 'Enjoying a sunny day at the park 🌳',
        'image': 'assets/images/post1.jpg',
        'likes': 120,
        'comments': 15,
      },
      {
        'username': 'jane smith',
        'avatar': 'assets/images/pagediary.png',
        'status': 'Exploring the river cleanup campaign 🚤',
        'image': 'assets/images/post2.jpg',
        'likes': 89,
        'comments': 7,
      },
    ];

    return Scaffold(
      backgroundColor: background, // Sử dụng màu nền từ colors.dart
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Avatar và tên người dùng
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(post['avatar']),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          post['username'],
                          style: const TextStyle(
                            fontFamily: 'Oktah',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.more_vert),
                      ],
                    ),
                  ),
                  // Status (mô tả)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      post['status'],
                      style: const TextStyle(
                        fontFamily: 'Oktah',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Hình ảnh bài viết
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      post['image'],
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Icon trái tim và bình luận
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.heart,
                          size: 20,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post['likes']}',
                          style: const TextStyle(
                            fontFamily: 'Oktah',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(
                          FontAwesomeIcons.comment,
                          size: 20,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post['comments']}',
                          style: const TextStyle(
                            fontFamily: 'Oktah',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
