import 'dart:math';
import 'package:flutter/material.dart';
import 'package:greenly_app/models/library.dart';
import 'package:greenly_app/models/process.dart' as model;
import 'package:greenly_app/services/process_service.dart';
import 'package:greenly_app/ui/pages/greenlibrary/process_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LibraryCard extends StatefulWidget {
  final LibraryDocument document;

  const LibraryCard({
    super.key,
    required this.document,
  });

  @override
  State<LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<LibraryCard> {
  String? categoryImage; // URL ảnh từ API (nếu có)
  String? fallbackImage; // asset local nếu API fail
  Color textColor = Colors.black;

  final ProcessService _processService = ProcessService();
  List<model.Step> steps = [];
  List<model.Flow> flows = [];

  final List<Color> colorPool = [
    Colors.teal,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.indigo,
    Colors.orange,
    Colors.cyan,
    Colors.brown,
  ];

  final List<String> fallbackAssets = [
    'assets/images/cleanriver.jpg',
    'assets/images/planting.png',
  ];

  @override
  void initState() {
    super.initState();
    textColor = colorPool[Random().nextInt(colorPool.length)];
    fallbackImage = fallbackAssets[Random().nextInt(fallbackAssets.length)];
    fetchCategoryImage();
    _loadProcess();
  }

  Future<void> _loadProcess() async {
    if (widget.document.processId != null) {
      final (fetchedSteps, fetchedFlows) =
          await _processService.fetchProcess(widget.document.processId!);
      setState(() {
        steps = fetchedSteps;
        flows = fetchedFlows;
      });
      // Sắp xếp các bước theo luồng
      steps = sortStepsByFlow(steps, flows);
    }
  }

  List<model.Step> sortStepsByFlow(
      List<model.Step> steps, List<model.Flow> flows) {
    // Map step_id -> Step để tra nhanh
    final stepMap = {for (var step in steps) step.stepId: step};

    // Map source_ref -> target_ref
    final flowMap = {for (var flow in flows) flow.sourceRef: flow.targetRef};

    // Tìm startEvent
    final startStep = steps.firstWhere(
      (s) => s.type == 'startEvent',
      orElse: () => model.Step(stepId: '', processId: '', type: ''),
    );

    // Nếu không tìm thấy startEvent, trả về steps gốc
    if (startStep.stepId == null) return steps;

    // Kết quả sắp xếp
    final sortedSteps = <model.Step>[];
    String? currentId = startStep.stepId;

    while (currentId != null) {
      final step = stepMap[currentId];
      if (step != null) sortedSteps.add(step);

      currentId = flowMap[currentId]; // Tiếp theo trong flow
    }

    return sortedSteps;
  }

  Future<void> fetchCategoryImage() async {
    if (widget.document.categoryId == null) return;
    try {
      final res = await http.get(Uri.parse(
          'http://localhost:3000/api/category/get/${widget.document.categoryId}'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final imgUrl = data['data']['image'];
        if (imgUrl != null && imgUrl.toString().isNotEmpty) {
          setState(() {
            categoryImage = imgUrl;
          });
        }
      }
    } catch (e) {
      print('❌ Lỗi lấy ảnh category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = categoryImage != null
        ? Image.network(categoryImage!, fit: BoxFit.cover)
        : Image.asset(fallbackImage!, fit: BoxFit.cover);

    return GestureDetector(
      onTap: () => {
        showDialog(
            context: context,
            builder: (_) => ProcessCard(
                  libraryName: widget.document.libraryName,
                  description: widget.document.description!,
                  processId: widget.document.processId!,
                  file: widget.document.file!,
                  steps: steps, // Pass the fetched steps to ProcessCard),
                ))
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        height: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: imageWidget,
            ),
            Positioned(
              top: 20,
              right: 35,
              width: (MediaQuery.of(context).size.width - 32) * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.document.libraryName,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'montserrat',
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(9.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'View Details',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'montserrat',
                        fontWeight: FontWeight.w700,
                        color: textColor.withOpacity(0.8),
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
  }
}
