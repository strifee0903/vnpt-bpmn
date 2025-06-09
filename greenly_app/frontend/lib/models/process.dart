class Process {
  final String processId;
  final String name;
  final List<Step> steps;
  final List<Flow> flows;

  Process({
    required this.processId,
    required this.name,
    required this.steps,
    required this.flows,
  });

  Process copyWith({
    String? processId,
    String? name,
    List<Step>? steps,
    List<Flow>? flows,
  }) {
    return Process(
      processId: processId ?? this.processId,
      name: name ?? this.name,
      steps: steps ?? this.steps,
      flows: flows ?? this.flows,
    );
  }

  factory Process.fromJson(Map<String, dynamic> json) {
    return Process(
      processId: json['process_id'].toString(),
      name: json['name']?.toString() ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((stepJson) => Step.fromJson(stepJson))
              .toList() ??
          [],
      flows: (json['flows'] as List<dynamic>?)
              ?.map((flowJson) => Flow.fromJson(flowJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'process_id': processId,
      'name': name,
      'steps': steps.map((step) => step.toJson()).toList(),
      'flows': flows.map((flow) => flow.toJson()).toList(),
    };
  }
}

class Step {
  final String stepId;
  final String processId;
  final String? name;
  final String type;

  Step({
    required this.stepId,
    required this.processId,
    this.name,
    required this.type,
  });

  Step copyWith({
    String? stepId,
    String? processId,
    String? name,
    String? type,
  }) {
    return Step(
      stepId: stepId ?? this.stepId,
      processId: processId ?? this.processId,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      stepId: json['step_id'].toString(),
      processId: json['process_id'].toString(),
      name: json['name']?.toString(),
      type: json['type'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_id': stepId,
      'process_id': processId,
      'name': name,
      'type': type,
    };
  }
}

class Flow {
  final String flowId;
  final String processId;
  final String sourceRef;
  final String targetRef;
  final String type;

  Flow({
    required this.flowId,
    required this.processId,
    required this.sourceRef,
    required this.targetRef,
    required this.type,
  });

  Flow copyWith({
    String? flowId,
    String? processId,
    String? sourceRef,
    String? targetRef,
    String? type,
  }) {
    return Flow(
      flowId: flowId ?? this.flowId,
      processId: processId ?? this.processId,
      sourceRef: sourceRef ?? this.sourceRef,
      targetRef: targetRef ?? this.targetRef,
      type: type ?? this.type,
    );
  }

  factory Flow.fromJson(Map<String, dynamic> json) {
    return Flow(
      flowId: json['flow_id'].toString(),
      processId: json['process_id'].toString(),
      sourceRef: json['source_ref'].toString(),
      targetRef: json['target_ref'].toString(),
      type: json['type'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flow_id': flowId,
      'process_id': processId,
      'source_ref': sourceRef,
      'target_ref': targetRef,
      'type': type,
    };
  }
}
