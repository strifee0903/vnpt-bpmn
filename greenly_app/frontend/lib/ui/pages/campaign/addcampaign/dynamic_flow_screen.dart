import 'package:flutter/material.dart';
import 'package:greenly_app/components/paths.dart';
import 'package:greenly_app/models/process.dart' as model;
import 'package:greenly_app/services/process_service.dart';
import 'package:greenly_app/ui/pages/campaign/addcampaign/success_dialog.dart';
import 'screen_register.dart';

class DynamicFlowPage extends StatefulWidget {
  const DynamicFlowPage({super.key});

  @override
  State<DynamicFlowPage> createState() => _DynamicFlowPageState();
}

class _DynamicFlowPageState extends State<DynamicFlowPage> {
  final processService = ProcessService();

  List<model.Process> dynamicProcesses = [];
  model.Process? selectedProcess;

  List<model.Step> steps = [];
  List<model.Flow> flows = [];
  List<model.Step> orderedSteps = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadDynamicProcesses();
  }

  Future<void> loadDynamicProcesses() async {
    dynamicProcesses = await processService.fetchAllDynamicProcesses();
    setState(() {});
  }

  Future<void> loadProcess(String processId) async {
    final (loadedSteps, loadedFlows) =
        await processService.fetchProcess(processId);
    steps = loadedSteps;
    flows = loadedFlows;
    orderedSteps = buildExecutionOrder();
    currentIndex = 0;
    setState(() {});
  }

  List<model.Step> buildExecutionOrder() {
    try {
      final List<model.Step> ordered = [];
      String? current = steps.firstWhere((s) => s.type == 'startEvent').stepId;

      while (true) {
        final nextFlow = flows.firstWhere(
          (f) => f.sourceRef == current,
          orElse: () => model.Flow(
            flowId: '',
            processId: '',
            sourceRef: '',
            targetRef: '',
            type: '',
          ),
        );

        if (nextFlow.targetRef.isEmpty) break;

        current = nextFlow.targetRef;

        final nextStep = steps.firstWhere(
          (s) => s.stepId == current && s.type == 'userTask',
          orElse: () => model.Step(
            stepId: '',
            processId: '',
            name: '',
            type: '',
          ),
        );

        if (nextStep.stepId.isNotEmpty) {
          ordered.add(nextStep);
        }

        if (steps.any((s) => s.stepId == current && s.type == 'endEvent')) {
          break;
        }
      }

      return ordered;
    } catch (e) {
      print('Error building execution order: $e');
      return [];
    }
  }

  void goToNext() {
    if (currentIndex < orderedSteps.length - 1) {
      if (orderedSteps[currentIndex].type == 'endEvent') return;
      setState(() => currentIndex++);
    }
  }

  void goToPrevious() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => const SuccessDialog(),
    );
  }

  void resetProcess() {
    selectedProcess = null;
    orderedSteps = [];
    steps = [];
    flows = [];
    currentIndex = 0;
    setState(() {});
  }

  void showProcessSelectorDialog() {
    model.Process? selected;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn quy trình động',
              style: TextStyle(
                  fontSize: 18, color: Color.fromARGB(255, 12, 51, 35))),
          content: DropdownButtonFormField<model.Process>(
            isExpanded: true,
            hint: const Text('Chọn 1 quy trình'),
            items: dynamicProcesses.map((p) {
              return DropdownMenuItem<model.Process>(
                value: p,
                child: Text(p.name),
              );
            }).toList(),
            onChanged: (value) {
              selected = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selected != null) {
                  Navigator.pop(context);
                  selectedProcess = selected;
                  await loadProcess(selected!.processId);
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedProcess == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chiến dịch xanh")),
        body: Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: button,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.playlist_add_check,
                color: Colors.white, size: 24),
            label: const Text("Chọn quy trình để bắt đầu",
                style: TextStyle(fontSize: 18, color: Colors.white)),
            onPressed: showProcessSelectorDialog,
          ),
        ),
      );
    }
    if (orderedSteps.isEmpty) {
      return const Scaffold(body: Center(child: Text('Đang tải quy trình...')));
    }

    final step = orderedSteps[currentIndex];
    final screenBuilder = screenRegistry[step.name];

    return Scaffold(
      body: screenBuilder != null
          ? screenBuilder(
              () {
                if (currentIndex < orderedSteps.length - 1) {
                  goToNext();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đến bước cuối cùng')),
                  );
                }
              },
              () => currentIndex == 0 ? Navigator.pop(context) : goToPrevious(),
              currentIndex == orderedSteps.length - 1,
              (String message) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Thông báo'),
                    content: Text(message),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            )
          : const Center(child: Text('Không có screen phù hợp')),
    );
  }
}
