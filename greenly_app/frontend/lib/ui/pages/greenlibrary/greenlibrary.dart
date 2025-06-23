import 'dart:convert'; // Thêm để sử dụng jsonDecode
import 'package:flutter/material.dart';
import '../../../components/colors.dart'; // Import colors.dart
import '../../../services/process_service.dart'; // Import ProcessService
import 'package:greenly_app/models/process.dart'; // Import file model Process
import 'library_card.dart';
import 'process_card.dart';

class GreenLibrary extends StatefulWidget {
  const GreenLibrary({super.key});

  @override
  _GreenLibraryState createState() => _GreenLibraryState();
}

class _GreenLibraryState extends State<GreenLibrary> {
  // Danh sách các chiến dịch xanh với processId thêm vào
  final List<Map<String, dynamic>> campaigns = [
    {
      'image': 'assets/images/planting.png',
      'title': 'ECO-FRIENDLY PLANTING',
      'textColor': const Color(0xFF320705),
      'processId': 'Process_174917473016', // Liên kết với processId mẫu
    },
    {
      'image': 'assets/images/cleanriver.jpg',
      'title': 'TRASH CLASSIFICATION',
      'textColor': const Color.fromARGB(255, 1, 9, 22),
      'processId': 'Process_1749449975796', // Liên kết với processId mẫu
    },
  ];

  // Biến để lưu thông tin process khi nhấn View Details
  Process? _selectedProcess;

  // Hàm hiển thị dialog với thông tin process (lấy từ /api/v1/bpmn/all)
  Future<void> _showProcessDialog(String processId) async {
    try {
      final response =
          await ProcessService().getAllProcesses(); // Sử dụng /api/v1/bpmn/all
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Debug dữ liệu thô
      print('BASE_URL: ${ProcessService.baseUrl}'); // Debug BASE_URL

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body); // Giải mã JSON
        print('Decoded JSON: $jsonData'); // Debug JSON đã giải mã

        // Kiểm tra cấu trúc JSON và lấy process đầu tiên
        if (jsonData is Map<String, dynamic> && jsonData['data'] != null) {
          final processList = jsonData['data'] as List<dynamic>;
          if (processList.isNotEmpty) {
            final processData = processList.firstWhere(
                (p) => p['id'] == processId,
                orElse: () => processList[
                    0]); // Tìm process theo processId, nếu không tìm thấy thì lấy process đầu tiên
            if (processData is! Map<String, dynamic>) {
              throw Exception('Invalid process data format: $processData');
            }
            final process = Process.fromJson(processData);

            setState(() {
              _selectedProcess = process;
            });

            // Hiển thị dialog bằng ProcessCard
            showDialog(
              context: context,
              builder: (context) => ProcessCard(processData: _selectedProcess),
            );
          } else {
            throw Exception('No processes found in the response');
          }
        } else {
          throw Exception('Unexpected JSON structure: $jsonData');
        }
      } else {
        throw Exception('Failed to load processes: ${response.body}');
      }
    } catch (e) {
      print('Error in _showProcessDialog: $e'); // Debug lỗi chi tiết
      _showErrorDialog(e.toString());
    }
  }

  // Hàm hiển thị dialog lỗi
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error',
            style: TextStyle(fontFamily: 'Oktah', fontWeight: FontWeight.w900)),
        content: Text('Failed to load process: $errorMessage',
            style: const TextStyle(fontFamily: 'Oktah')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
            },
            child: const Text('Close',
                style: TextStyle(fontFamily: 'Oktah', color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0, // Không có bóng đổ
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
            return LibraryCard(
              image: campaign['image'],
              title: campaign['title'],
              textColor: campaign['textColor'],
              processId: campaign['processId'],
              onTap: _showProcessDialog,
            );
          },
        ),
      ),
    );
  }
}
