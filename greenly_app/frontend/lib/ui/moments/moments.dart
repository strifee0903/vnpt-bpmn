import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../components/colors.dart'; // Import colors.dart
import 'moments_card.dart'; // Import MomentCard

class MomentsPage extends StatefulWidget {
  const MomentsPage({super.key});

  @override
  _MomentsPageState createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
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
          return MomentCard(
            username: post['username'],
            avatar: post['avatar'],
            status: post['status'],
            image: post['image'],
            likes: post['likes'],
            comments: post['comments'],
          );
        },
      ),
    );
  }
}
