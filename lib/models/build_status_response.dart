import 'build_step_item.dart';

class BuildStatusResponse {
  final String status;
  final String? conclusion;
  final int? runNumber;
  final int? currentStep;
  final int? totalSteps;
  final String? stepName;
  final String? error;
  final List<BuildStepItem>? steps;

  BuildStatusResponse({
    required this.status,
    this.conclusion,
    this.runNumber,
    this.currentStep,
    this.totalSteps,
    this.stepName,
    this.error,
    this.steps,
  });

  bool get isCompleted => status == 'completed';
  bool get isRunning => status == 'in_progress' || status == 'queued';
  bool get isSuccess => isCompleted && conclusion == 'success';
  bool get isFailed => isCompleted && conclusion == 'failure';

  factory BuildStatusResponse.fromJson(Map<String, dynamic> json) {
    List<BuildStepItem>? steps;
    if (json['steps'] != null) {
      steps = (json['steps'] as List)
          .map((s) => BuildStepItem.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return BuildStatusResponse(
      status: json['status'] as String,
      conclusion: json['conclusion'] as String?,
      runNumber: json['run_number'] as int?,
      currentStep: json['current_step'] as int?,
      totalSteps: json['total_steps'] as int?,
      stepName: json['step_name'] as String?,
      error: json['error'] as String?,
      steps: steps,
    );
  }
}
