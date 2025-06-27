import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../components/colors.dart';
import 'package:greenly_app/models/process.dart' as model;
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> openPdfFromUrl(String url) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final savePath = '${tempDir.path}/temp_file.pdf';

    // Tải file về
    final response = await Dio().download(url, savePath);

    if (response.statusCode == 200) {
      await OpenFilex.open(savePath);
    } else {
      throw Exception('Không tải được file.');
    }
  } catch (e) {
    print('❌ Lỗi mở file: $e');
  }
}

class ProcessCard extends StatefulWidget {
  final String libraryName;
  final String description;
  final String processId;
  final String file;
  final List<model.Step> steps;

  const ProcessCard({
    super.key,
    required this.libraryName,
    required this.description,
    required this.processId,
    required this.file,
    required this.steps,
  });

  @override
  State<ProcessCard> createState() => _ProcessCardState();
}

class _ProcessCardState extends State<ProcessCard> {
  @override
  void initState() {
    super.initState();
  }

  // Future<void> fetchProcessSteps(String processId) async {
  //   try {
  //     final res = await http.get(
  //       Uri.parse('http://localhost:3000/api/v1/bpmn/details/$processId'),
  //     );

  //     if (res.statusCode == 200) {
  //       final data = json.decode(res.body);
  //       final allSteps = data['data']['steps'] ?? [];
  //       setState(() {
  //         steps = allSteps;
  //       });
  //     } else {
  //       print('⚠️ Không thể tải quy trình.');
  //     }
  //   } catch (e) {
  //     print('❌ Lỗi khi lấy process: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final pdfUrl = 'http://10.0.2.2:3000/${widget.file.split('/').last}';
    print('PDF URL: $pdfUrl');
    return AlertDialog(
      backgroundColor: background,
      title: Text(
        widget.libraryName,
        style: const TextStyle(
          fontFamily: 'Oktah',
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.description,
              style: const TextStyle(
                fontFamily: 'Oktah',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                openPdfFromUrl(pdfUrl);
              },
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '📄 ${widget.file.split('/').last.split('\\').last}',
                      style: const TextStyle(fontFamily: 'Oktah'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quy trình thực hiện:',
              style: TextStyle(
                fontFamily: 'Oktah',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.steps.isNotEmpty)
              Column(
                children: widget.steps.asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isOdd = index % 2 == 0;

                  // Xác định loại bước và nội dung
                  final isStart = step.type == 'startEvent';
                  final isEnd = step.type == 'endEvent';
                  final isTask = step.type == 'task' || step.type == 'userTask';

                  String title;
                  IconData icon;
                  Color bgColor;
                  Color textColor;

                  if (isStart) {
                    title = '🔰 Bắt đầu';
                    icon = Icons.play_arrow;
                    bgColor = Colors.green.shade100;
                    textColor = Colors.green.shade800;
                  } else if (isEnd) {
                    title = '🏁 Kết thúc';
                    icon = Icons.flag;
                    bgColor = Colors.red.shade100;
                    textColor = Colors.red.shade800;
                  } else {
                    title = step.name?.toString().trim().isNotEmpty == true
                        ? step.name!
                        : '(Không tên)';
                    icon = Icons.check_circle_outline;
                    bgColor = isOdd
                        ? const Color.fromARGB(255, 219, 225, 211)
                        : button;
                    textColor = isOdd
                        ? const Color.fromARGB(255, 15, 69, 17)
                        : Colors.white;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: bgColor,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, color: textColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Step ${index + 1}',
                                  style: TextStyle(
                                    fontFamily: 'Oktah',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: 'Oktah',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              const Text('Không có bước nào.',
                  style: TextStyle(fontFamily: 'Oktah')),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Đóng',
            style: TextStyle(
              fontFamily: 'Oktah',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: button,
            ),
          ),
        )
      ],
    );
  }
}
