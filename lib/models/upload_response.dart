class UploadResponse {
  final bool ok;
  final String jobId;
  final int assetId;
  final String sourceUrl;

  UploadResponse({
    required this.ok,
    required this.jobId,
    required this.assetId,
    required this.sourceUrl,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      ok: json['ok'] as bool? ?? true,
      jobId: json['job_id'] as String,
      assetId: json['asset_id'] as int,
      sourceUrl: json['source_url'] as String,
    );
  }
}
