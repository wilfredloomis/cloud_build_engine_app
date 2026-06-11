class BuildLogsResponse {
  final String? runId;
  final String? workflowJobId;
  final String? workflowJobName;
  final String log;
  final bool ready;

  BuildLogsResponse({
    this.runId,
    this.workflowJobId,
    this.workflowJobName,
    required this.log,
    required this.ready,
  });

  factory BuildLogsResponse.fromJson(Map<String, dynamic> json) {
    return BuildLogsResponse(
      runId: json['run_id'] as String?,
      workflowJobId: json['workflow_job_id'] as String?,
      workflowJobName: json['workflow_job_name'] as String?,
      log: json['log'] as String? ?? '',
      ready: json['ready'] as bool? ?? false,
    );
  }
}
