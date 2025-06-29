// import 'package:flutter/material.dart';
// import 'package:greenly_app/models/process.dart' as model;
// import 'package:greenly_app/services/process_service.dart';
// import 'screen_register.dart';

// class DynamicFlowPage extends StatefulWidget {
//   const DynamicFlowPage({super.key});

//   @override
//   State<DynamicFlowPage> createState() => _DynamicFlowPageState();
// }

// class _DynamicFlowPageState extends State<DynamicFlowPage> {
//   List<model.Step> steps = [];
//   List<model.Flow> flows = [];
//   List<model.Step> orderedSteps = [];
//   int currentIndex = 0;

//   final processService = ProcessService();

//   @override
//   void initState() {
//     super.initState();
//     loadProcess();
//   }

// <<<<<<< HEAD
//   Future<void> loadProcess() async {
//     final (loadedSteps, loadedFlows) =
//         await processService.fetchProcess("Process_17501703319112");
//     print('Loaded Steps: ${loadedSteps.length}, Flows: ${loadedFlows.length}');
//     for (var step in loadedSteps) {
//       print('Step: ${step.stepId}, Type: ${step.type}');
//     }
//     for (var flow in loadedFlows) {
//       print(
//           'Flow: ${flow.flowId}, Source: ${flow.sourceRef}, Target: ${flow.targetRef}');
//     }
// =======
//   Future<void> loadProcess() async {
//     final (loadedSteps, loadedFlows) = await processService.fetchProcess();
//     print('Loaded Steps: ${loadedSteps.length}, Flows: ${loadedFlows.length}');
//     for (var step in loadedSteps) {
//       print('Step: ${step.stepId}, Type: ${step.type}');
//     }
//     for (var flow in loadedFlows) {
//       print(
//           'Flow: ${flow.flowId}, Source: ${flow.sourceRef}, Target: ${flow.targetRef}');
//     }
// >>>>>>> 059dac5bfe1cf0b772b020c48a5f9c3589c1fea5

//     steps = loadedSteps;
//     flows = loadedFlows;
//     orderedSteps = buildExecutionOrder();
//     print('Ordered Steps: ${orderedSteps.length}');
//     for (var step in orderedSteps) {
//       print('Ordered Step: ${step.stepId}, Type: ${step.type}');
//     }
//     setState(() {});
//   }

//   List<model.Step> buildExecutionOrder() {
//     try {
//       final List<model.Step> ordered = [];
//       String? current = steps.firstWhere((s) => s.type == 'startEvent').stepId;

//       while (true) {
//         final nextFlow = flows.firstWhere(
//           (f) => f.sourceRef == current,
//           orElse: () => model.Flow(
//             flowId: '',
//             processId: '',
//             sourceRef: '',
//             targetRef: '',
//             type: '',
//           ),
//         );

//         if (nextFlow.targetRef.isEmpty) break;

//         current = nextFlow.targetRef;

//         final nextStep = steps.firstWhere(
//           (s) => s.stepId == current && s.type == 'userTask',
//           orElse: () => model.Step(
//             stepId: '',
//             processId: '',
//             name: '',
//             type: '',
//           ),
//         );

//         if (nextStep.stepId.isNotEmpty) {
//           ordered.add(nextStep);
//         }

//         // Nếu bước hiện tại là endEvent thì dừng
//         if (steps.any((s) => s.stepId == current && s.type == 'endEvent')) {
//           break;
//         }
//       }

//       return ordered;
//     } catch (e) {
//       print('Error building execution order: $e');
//       return [];
//     }
//   }

//   void goToNext() {
//     if (currentIndex < orderedSteps.length - 1) {
//       // Kiểm tra xem bước hiện tại có phải là endEvent không
//       if (orderedSteps[currentIndex].type == 'endEvent') {
//         // Nếu là endEvent thì không cho đi tiếp
//         return;
//       }
//       // Nếu không phải là endEvent thì cho phép đi tiếp
//       // và tăng currentIndex
//       print(
//           'Current Index: $currentIndex, Next Step: ${orderedSteps[currentIndex + 1].stepId}');
//       setState(() => currentIndex++);
//     }
//   }

//   void goToPrevious() {
//     if (currentIndex > 0) {
//       // Giảm currentIndex nếu không phải là bước đầu tiên
//       print(
//           'Current Index: $currentIndex, Previous Step: ${orderedSteps[currentIndex - 1].stepId}');
//       setState(() => currentIndex--);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (orderedSteps.isEmpty) {
//       return const Scaffold(body: Center(child: Text('dataLoading...')));
//     }
//     final step = orderedSteps[currentIndex];
//     final screenBuilder = screenRegistry[step.name];

//     return Scaffold(
//       appBar: AppBar(title: Text(step.name!)),
//       body: screenBuilder != null
//           ? screenBuilder()
//           : const Center(child: Text('Không có screen phù hợp')),
//       bottomNavigationBar: BottomAppBar(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             TextButton(
//               onPressed: goToPrevious,
//               child: const Text('Quay lại'),
//             ),
//             TextButton(
//               onPressed: goToNext,
//               child: const Text('Tiếp tục'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
