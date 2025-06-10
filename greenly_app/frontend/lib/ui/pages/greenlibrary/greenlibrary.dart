import 'dart:convert'; // Thêm để sử dụng jsonDecode
import 'package:flutter/material.dart';
import '../../../components/colors.dart'; // Import colors.dart
import '../../../services/process_service.dart'; // Import ProcessService
import 'package:greenly_app/models/process.dart'; // Import file model Process

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

  // Hàm hiển thị dialog với thông tin process
  Future<void> _showProcessDialog(String processId) async {
    try {
      final response = await ProcessService().getProcessDetails(processId);
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Debug dữ liệu thô
      print('BASE_URL: ${ProcessService.baseUrl}'); // Debug BASE_URL

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body); // Giải mã JSON
        // Xử lý trường hợp JSON có key 'data'
        if (jsonData is Map<String, dynamic> && jsonData['data'] != null) {
          final processData = (jsonData['data'] as List<dynamic>).firstWhere(
            (item) => item['process_id'] == processId,
            orElse: () =>
                throw Exception('Process not found with ID: $processId'),
          );
          if (processData is! Map<String, dynamic>) {
            throw Exception('Invalid process data format');
          }
          final process = Process.fromJson(processData);

          setState(() {
            _selectedProcess = process;
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Process Details',
                style:
                    TextStyle(fontFamily: 'Oktah', fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Process ID: ${_selectedProcess?.processId ?? 'N/A'}',
                        style: const TextStyle(fontFamily: 'Oktah')),
                    Text('Name: ${_selectedProcess?.name ?? 'N/A'}',
                        style: const TextStyle(fontFamily: 'Oktah')),
                    const SizedBox(height: 10),
                    const Text('Steps:',
                        style: TextStyle(
                            fontFamily: 'Oktah', fontWeight: FontWeight.bold)),
                    ..._selectedProcess?.steps.map((step) => Text(
                              '- ${step.stepId} (${step.type})',
                              style: const TextStyle(fontFamily: 'Oktah'),
                            )) ??
                        [
                          const Text('No steps available',
                              style: TextStyle(fontFamily: 'Oktah'))
                        ],
                    const SizedBox(height: 10),
                    const Text('Flows:',
                        style: TextStyle(
                            fontFamily: 'Oktah', fontWeight: FontWeight.bold)),
                    ..._selectedProcess?.flows.map((flow) => Text(
                              '- ${flow.flowId} (${flow.sourceRef} -> ${flow.targetRef})',
                              style: const TextStyle(fontFamily: 'Oktah'),
                            )) ??
                        [
                          const Text('No flows available',
                              style: TextStyle(fontFamily: 'Oktah'))
                        ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng dialog
                  },
                  child: const Text('Close',
                      style:
                          TextStyle(fontFamily: 'Oktah', color: Colors.green)),
                ),
              ],
            ),
          );
        } else {
          throw Exception('Unexpected JSON structure: $jsonData');
        }
      } else {
        throw Exception('Failed to load process: ${response.body}');
      }
    } catch (e) {
      print('Error in _showProcessDialog: $e'); // Debug lỗi chi tiết
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error',
              style:
                  TextStyle(fontFamily: 'Oktah', fontWeight: FontWeight.w900)),
          content: Text('Failed to load process: $e',
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
  }

  @override
  Widget build(BuildContext context) {
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
            return GestureDetector(
              onTap: () {
                _showProcessDialog(campaign['processId']);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        campaign['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 35,
                      width: (MediaQuery.of(context).size.width - 32) * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            campaign['title'],
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Oktah',
                              fontWeight: FontWeight.w900,
                              color: campaign['textColor'],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(9.0),
                            decoration: BoxDecoration(
                              color: background,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              'View Details',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Oktah',
                                fontWeight: FontWeight.w700,
                                color: campaign['textColor'].withOpacity(0.8),
                              ),
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
      ),
    );
  }
}
