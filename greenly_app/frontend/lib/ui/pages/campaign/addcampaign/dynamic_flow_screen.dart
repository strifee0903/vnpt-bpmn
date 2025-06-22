import 'package:flutter/material.dart';
import 'package:greenly_app/models/process.dart' as model;
import 'package:greenly_app/services/process_service.dart';
import 'package:greenly_app/ui/pages/campaign/addcampaign/success_dialog.dart';
import 'screen_register.dart';
import '../../../../components/colors.dart';

class DynamicFlowPage extends StatefulWidget {
  const DynamicFlowPage({super.key});

  @override
  State<DynamicFlowPage> createState() => _DynamicFlowPageState();
}

class _DynamicFlowPageState extends State<DynamicFlowPage> {
  List<model.Step> steps = [];
  List<model.Flow> flows = [];
  List<model.Step> orderedSteps = [];
  int currentIndex = 0;

  final processService = ProcessService();

  @override
  void initState() {
    super.initState();
    loadProcess();
  }

  Future<void> loadProcess() async {
    final (loadedSteps, loadedFlows) = await processService.fetchProcess();
    print('Loaded Steps: ${loadedSteps.length}, Flows: ${loadedFlows.length}');
    for (var step in loadedSteps) {
      print('Step: ${step.stepId}, Type: ${step.type}');
    }
    for (var flow in loadedFlows) {
      print(
          'Flow: ${flow.flowId}, Source: ${flow.sourceRef}, Target: ${flow.targetRef}');
    }

    steps = loadedSteps;
    flows = loadedFlows;
    orderedSteps = buildExecutionOrder();
    print('Ordered Steps: ${orderedSteps.length}');
    for (var step in orderedSteps) {
      print('Ordered Step: ${step.stepId}, Type: ${step.type}');
    }
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

        // Nếu bước hiện tại là endEvent thì dừng
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
      // Kiểm tra xem bước hiện tại có phải là endEvent không
      if (orderedSteps[currentIndex].type == 'endEvent') {
        // Nếu là endEvent thì không cho đi tiếp
        return;
      }
      // Nếu không phải là endEvent thì cho phép đi tiếp
      // và tăng currentIndex
      print(
          'Current Index: $currentIndex, Next Step: ${orderedSteps[currentIndex + 1].stepId}');
      setState(() => currentIndex++);
    }
  }

  void goToPrevious() {
    if (currentIndex > 0) {
      // Giảm currentIndex nếu không phải là bước đầu tiên
      print(
          'Current Index: $currentIndex, Previous Step: ${orderedSteps[currentIndex - 1].stepId}');
      setState(() => currentIndex--);
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => const SuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (orderedSteps.isEmpty) {
      return const Scaffold(body: Center(child: Text('dataLoading...')));
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
                  // Nếu đã đến bước cuối cùng, có thể hiển thị thông báo hoặc làm gì đó
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đến bước cuối cùng')),
                  );
                }
              },
              goToPrevious,
              currentIndex == orderedSteps.length - 1 ? true : false,
              (String message) {
                // ✅ onComplete callback
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Thông báo'),
                    content: Text(message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          goToNext();
                        },
                        child: const Text('OK'),
                      )
                    ],
                  ),
                );
              },
            )
          : const Center(child: Text('Không có screen phù hợp')),
    );
  }
}
