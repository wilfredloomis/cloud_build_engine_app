class BuildJob {
  final String jobId;
  final String? runId;
  final String appName;
  final String packageName;
  final String buildMode;
  final String projectType;
  final String status;
  final String? conclusion;
  final int currentStep;
  final int totalSteps;
  final String? artifactId;
  final String? apkPath;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;

  BuildJob({
    required this.jobId,
    this.runId,
    required this.appName,
    required this.packageName,
    required this.buildMode,
    required this.projectType,
    required this.status,
    this.conclusion,
    required this.currentStep,
    required this.totalSteps,
    this.artifactId,
    this.apkPath,
    this.error,
    required this.createdAt,
    this.completedAt,
  });

  bool get isRunning =>
      status == 'queued' || status == 'in_progress' || status == 'uploading';

  bool get isSuccess => status == 'completed' && conclusion == 'success';

  bool get isFailed =>
      status == 'completed' &&
      (conclusion == 'failure' || conclusion == 'timed_out');

  bool get isCancelled => status == 'completed' && conclusion == 'cancelled';

  double get progress =>
      totalSteps > 0 ? currentStep / totalSteps : 0.0;

  Duration? get duration {
    if (completedAt != null) {
      return completedAt!.difference(createdAt);
    }
    if (isRunning) {
      return DateTime.now().difference(createdAt);
    }
    return null;
  }

  String get statusDisplay {
    switch (status) {
      case 'created':
        return 'Waiting';
      case 'uploading':
        return 'Uploading...';
      case 'uploaded':
        return 'Uploaded';
      case 'queued':
        return 'Queued';
      case 'in_progress':
        return 'Building';
      case 'completed':
        switch (conclusion) {
          case 'success':
            return 'Success';
          case 'failure':
            return 'Failed';
          case 'cancelled':
            return 'Cancelled';
          case 'timed_out':
            return 'Timed Out';
          default:
            return 'Completed';
        }
      default:
        return status;
    }
  }

  BuildJob copyWith({
    String? jobId,
    String? runId,
    String? appName,
    String? packageName,
    String? buildMode,
    String? projectType,
    String? status,
    String? conclusion,
    int? currentStep,
    int? totalSteps,
    String? artifactId,
    String? apkPath,
    String? error,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return BuildJob(
      jobId: jobId ?? this.jobId,
      runId: runId ?? this.runId,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      buildMode: buildMode ?? this.buildMode,
      projectType: projectType ?? this.projectType,
      status: status ?? this.status,
      conclusion: conclusion ?? this.conclusion,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      artifactId: artifactId ?? this.artifactId,
      apkPath: apkPath ?? this.apkPath,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'runId': runId,
      'appName': appName,
      'packageName': packageName,
      'buildMode': buildMode,
      'projectType': projectType,
      'status': status,
      'conclusion': conclusion,
      'currentStep': currentStep,
      'totalSteps': totalSteps,
      'artifactId': artifactId,
      'apkPath': apkPath,
      'error': error,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory BuildJob.fromJson(Map<String, dynamic> json) {
    return BuildJob(
      jobId: json['jobId'] as String,
      runId: json['runId'] as String?,
      appName: json['appName'] as String,
      packageName: json['packageName'] as String,
      buildMode: json['buildMode'] as String,
      projectType: json['projectType'] as String,
      status: json['status'] as String,
      conclusion: json['conclusion'] as String?,
      currentStep: json['currentStep'] as int? ?? 0,
      totalSteps: json['totalSteps'] as int? ?? 26,
      artifactId: json['artifactId'] as String?,
      apkPath: json['apkPath'] as String?,
      error: json['error'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
