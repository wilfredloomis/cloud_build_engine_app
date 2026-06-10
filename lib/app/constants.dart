class AppConstants {
  AppConstants._();

  static const String appName = 'Cloud Build Engine';
  static const String appVersion = '1.0.0';

  // API base URL - point to your Cloudflare Worker
  static const String apiBaseUrl = 'https://cloud-workflow-engine.jefflumber341.workers.dev';

  // Build statuses
  static const String statusCreated = 'created';
  static const String statusUploading = 'uploading';
  static const String statusUploaded = 'uploaded';
  static const String statusQueued = 'queued';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';

  // Conclusions
  static const String conclusionSuccess = 'success';
  static const String conclusionFailure = 'failure';
  static const String conclusionCancelled = 'cancelled';
  static const String conclusionTimedOut = 'timed_out';

  // Build modes
  static const String modeRelease = 'release';
  static const String modeDebug = 'debug';
  static const String modeProfile = 'profile';

  // Project types
  static const String typeAuto = 'auto';
  static const String typeFlutter = 'flutter';
  static const String typeReactNative = 'react_native';
  static const String typeExpo = 'expo';
  static const String typeNativeAndroid = 'native_android';

  // Polling
  static const Duration pollInterval = Duration(seconds: 5);

  // Limits
  static const int maxZipSizeMB = 100;
  static const int maxZipSizeBytes = maxZipSizeMB * 1024 * 1024;

  // Default Flutter version (requires Java 17, matching the CI build JDK)
  static const String defaultFlutterVersion = '3.44.1';

  // Storage keys
  static const String storageKeyBuildJobs = 'build_jobs';
  static const String storageKeyApiUrl = 'api_url';
}
