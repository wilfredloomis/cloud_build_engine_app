class PrepareUploadResponse {
  final String jobId;
  final String uploadUrl;
  final String? assetName;
  final String? uploadMethod;

  PrepareUploadResponse({
    required this.jobId,
    required this.uploadUrl,
    this.assetName,
    this.uploadMethod,
  });

  factory PrepareUploadResponse.fromJson(Map<String, dynamic> json) {
    return PrepareUploadResponse(
      jobId: json['job_id'] as String,
      uploadUrl: json['upload_url'] as String,
      assetName: json['asset_name'] as String?,
      uploadMethod: json['upload_method'] as String?,
    );
  }
}
