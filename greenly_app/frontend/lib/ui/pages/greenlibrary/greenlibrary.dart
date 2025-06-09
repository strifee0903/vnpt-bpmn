import 'package:flutter/material.dart';
import '../../../components/colors.dart'; // Import colors.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GreenLibrary extends StatelessWidget {
  const GreenLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách các chiến dịch xanh với thuộc tính tùy chỉnh
    final List<Map<String, dynamic>> campaigns = [
      {
        'image': 'assets/images/planting.png', // Hình ảnh placeholder
        'title': 'ECO-FRIENDLY PLANTING',
        'textColor': const Color(0xFF320705), // Màu chữ tùy chỉnh
      },
      {
        'image': 'assets/images/cleanriver.jpg', // Hình ảnh placeholder
        'title': 'TRASH CLASSIFICATION',
        'textColor': const Color.fromARGB(255, 1, 9, 22), // Màu chữ tùy chỉnh
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Green Library',
          style: TextStyle(
            fontFamily: 'Oktah',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: campaigns.length,
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              height: 140, // Giữ nguyên chiều cao cho đồng bộ
              child: Stack(
                fit: StackFit.expand, // Hình ảnh chiếm toàn bộ container
                children: [
                  // Hình ảnh toàn kích thước
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      campaign['image'],
                      fit: BoxFit.cover, // Đảm bảo hình ảnh phủ kín khu vực
                    ),
                  ),
                  // Tiêu đề và View Details phủ lên, căn ở góc trên bên phải và chiếm 6/10 phần chiều rộng
                  Positioned(
                    top: 20,
                    right: 35,
                    width: (MediaQuery.of(context).size.width - 32) *
                        0.6, // 6/10 phần chiều rộng của banner
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end, // Căn phải cho cả cột
                      children: [
                        Text(
                          campaign['title'],
                          textAlign: TextAlign.right, // Căn lề phải cho văn bản
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Oktah',
                            fontWeight: FontWeight.w900,
                            color: campaign['textColor'], // Màu chữ tùy chỉnh
                          ),
                        ),
                        const SizedBox(
                            height:
                                4), // Khoảng cách giữa title và View Details
                        Container(
                          padding: const EdgeInsets.all(9.0), // Padding cho box
                          decoration: BoxDecoration(
                            color: background, // Màu nền trắng
                            borderRadius:
                                BorderRadius.circular(10.0), // Bo tròn góc
                          ),
                          child: Text(
                            'View Details',
                            textAlign: TextAlign.right, // Căn lề phải
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Oktah',
                              fontWeight: FontWeight.w700,
                              color: campaign['textColor']
                                  .withOpacity(0.8), // Màu chữ nhạt hơn
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
