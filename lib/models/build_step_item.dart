class BuildStepItem {
  final String name;
  final String status;
  final String? conclusion;
  final int number;

  BuildStepItem({
    required this.name,
    required this.status,
    this.conclusion,
    required this.number,
  });

  bool get isPending => status == 'pending' || status == 'queued';
  bool get isRunning => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isSuccess => conclusion == 'success';
  bool get isFailed => conclusion == 'failure';
  bool get isSkipped => conclusion == 'skipped';

  factory BuildStepItem.fromJson(Map<String, dynamic> json) {
    return BuildStepItem(
      name: json['name'] as String,
      status: json['status'] as String,
      conclusion: json['conclusion'] as String?,
      number: json['number'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'conclusion': conclusion,
      'number': number,
    };
  }

  static List<BuildStepItem> defaultSteps() {
    final stepNames = [
      'Set up job',
      'Install system dependencies',
      'Set up Java 17',
      'Download source code',
      'Clean up staging files',
      'Extract source code',
      'Patch gradle.properties',
      'Detect project type',
      'Set up Flutter',
      'Set up Node.js',
      'Set up Android SDK',
      'Accept Android licenses',
      'Install NDK and SDK platform',
      'Cache Gradle packages',
      'Cache npm packages',
      'Patch package name and app name',
      'Set up signing keystore',
      'Auto-fix Gradle issues',
      'Expo prebuild',
      'Patch Flutter ProGuard rules',
      'Build Flutter APK',
      'Build React Native APK',
      'Build Native Android APK',
      'Sign APK',
      'Upload APK artifact',
      'Build summary',
    ];

    return List.generate(
      stepNames.length,
      (i) => BuildStepItem(
        name: stepNames[i],
        status: 'pending',
        number: i + 1,
      ),
    );
  }
}
