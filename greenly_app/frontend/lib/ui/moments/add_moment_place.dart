import 'package:flutter/material.dart';
import 'package:greenly_app/components/colors.dart';
import 'add_moment.dart'; // Import trang add_moment.dart

class AddMomentPlace extends StatelessWidget {
  const AddMomentPlace({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMomentPage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị avatar và tên người dùng
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: background,
                  backgroundImage: const AssetImage(
                      'assets/images/blankava.png'), // Thay bằng avatar thực tế
                ),
                const SizedBox(width: 12.0),
                const Text(
                  'Mahmud Nik', // Tên người dùng mẫu, có thể thay bằng biến động
                  style: TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0), // Khoảng cách giữa avatar/tên và hint
            // Dòng hint (không có khung)
            Padding(
              padding: const EdgeInsets.only(left: 2), // Giữ padding để căn đều
              child: const Text(
                'Add a post or moment to share with others...',
                style: TextStyle(
                  fontFamily: 'Oktah',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(137, 42, 41, 41),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
