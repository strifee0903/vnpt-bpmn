import 'package:flutter/material.dart';
import '../../../components/colors.dart'; // Import colors.dart
import 'package:greenly_app/models/process.dart'
    as process; // Sử dụng prefix 'process'

class ProcessCard extends StatelessWidget {
  final process.Process? processData; // Đổi tên tham số thành processData

  const ProcessCard({super.key, required this.processData});

  @override
  Widget build(BuildContext context) {
    if (processData == null) {
      return AlertDialog(
        title: const Text(
          'Process Details',
          style: TextStyle(fontFamily: 'Oktah', fontWeight: FontWeight.w900),
        ),
        content: const Text('No process data available',
            style: TextStyle(fontFamily: 'Oktah')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close',
                style: TextStyle(fontFamily: 'Oktah', color: Colors.green)),
          ),
        ],
      );
    }

    // Lấy danh sách steps
    final steps = [...processData!.steps.whereType<process.Step>()];

    return AlertDialog(
      backgroundColor: background, // Đặt màu nền là background
      title: const Text(
        'ECO FRIENDLY PLANTING',
        style: TextStyle(
            fontFamily: 'Oktah',
            fontWeight: FontWeight.w900,
            color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn trái toàn bộ flow
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A demo description for eco-friendly planting initiatives to promote sustainability.',
              style: TextStyle(
                fontFamily: 'Oktah',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black54, // Màu mờ hơn để phân biệt với tiêu đề
              ),
            ),
            const SizedBox(
                height: 10), // Khoảng cách giữa mô tả và Process Name
            Text('Process: ',
                style: const TextStyle(
                    fontFamily: 'Oktah',
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (steps.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.start, // Căn trên
                crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa
                children: steps.asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isOdd = index % 2 == 0;
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 20.0), // Khoảng cách giữa các step
                    child: Container(
                      width: double.infinity, // Tràn ra hết chiều ngang dialog
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical:
                              12.0), // Điều chỉnh padding bên trong ô step
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: isOdd
                            ? const Color.fromARGB(
                                255, 219, 225, 211) // Màu nền cho step lẻ
                            : button, // Màu nền cho step chẵn
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Căn trái nội dung
                        children: [
                          Text(
                            'Step ${index + 1}', // Số thứ tự cho từng step (1, 2, 3, 4, ...)
                            style: TextStyle(
                              fontFamily: 'Oktah',
                              color: isOdd
                                  ? const Color.fromARGB(255, 15, 69, 17)
                                  : Colors
                                      .white, // Chữ đen cho lẻ, trắng cho chẵn
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Khoảng cách giữa số thứ tự và tên
                          Text(
                            step.name ?? 'No Name',
                            textAlign: TextAlign.left, // Căn trái tên step
                            softWrap: true, // Cho phép xuống dòng
                            style: TextStyle(
                              fontFamily: 'Oktah',
                              color: isOdd
                                  ? const Color.fromARGB(255, 15, 69, 17)
                                  : Colors
                                      .white, // Chữ đen cho lẻ, trắng cho chẵn
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            if (steps.isEmpty)
              const Text('No steps available',
                  style: TextStyle(fontFamily: 'Oktah')),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(
              bottom: 0, right: 4.0), // Giữ nút ở góc phải
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
            },
            child: Text(
              'Close',
              style: TextStyle(
                  fontFamily: 'Oktah',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: button // Màu button cho chữ
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
