import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MomentCard extends StatelessWidget {
  final String username;
  final String avatar;
  final String status;
  final String image;
  final int likes;
  final int comments;

  const MomentCard({
    super.key,
    required this.username,
    required this.avatar,
    required this.status,
    required this.image,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Avatar và tên người dùng
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(avatar),
              ),
              const SizedBox(width: 15),
              Text(
                username,
                style: const TextStyle(
                  fontFamily: 'Oktah',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
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
            status,
            style: const TextStyle(
              fontFamily: 'Oktah',
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Hình ảnh bài viết (toàn chiều ngang, không padding)
        Image.asset(
          image,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
        // Icon yêu thích và bình luận (dời sang lề trái)
        Padding(
          padding: const EdgeInsets.only(left: 18.0, top: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // Căn trái
            children: [
              Icon(
                FontAwesomeIcons.heart,
                size: 28,
                color: Colors.black, // Viền đen
              ),
              const SizedBox(width: 6),
              Text(
                '$likes',
                style: const TextStyle(
                  fontFamily: 'Oktah',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                FontAwesomeIcons.comment,
                size: 28,
                color: Colors.black, // Viền đen
              ),
              const SizedBox(width: 6),
              Text(
                '$comments',
                style: const TextStyle(
                  fontFamily: 'Oktah',
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10), // Khoảng cách giữa các post
      ],
    );
  }
}
