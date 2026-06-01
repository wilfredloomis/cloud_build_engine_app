class DispatchResponse {
  final bool ok;
  final String jobId;
  final String runId;
  final int? runNumber;

  DispatchResponse({
    required this.ok,
    required this.jobId,
    required this.runId,
    this.runNumber,
  });

  factory DispatchResponse.fromJson(Map<String, dynamic> json) {
    return DispatchResponse(
      ok: json['ok'] as bool? ?? true,
      jobId: json['job_id'] as String,
      runId: json['run_id'] as String,
      runNumber: json['run_number'] as int?,
    );
  }
}
