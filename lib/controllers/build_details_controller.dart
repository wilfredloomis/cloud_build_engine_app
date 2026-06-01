import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/build_job.dart';
import '../models/build_step_item.dart';
import '../models/build_status_response.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/artifact_service.dart';
import '../app/constants.dart';

class BuildDetailsController extends ChangeNotifier {
  final ApiService apiService;
  final LocalStorageService storageService;
  final ArtifactService _artifactService = ArtifactService();

  BuildJob? _job;
  List<BuildStepItem> _steps = [];
  Timer? _pollTimer;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _error;

  BuildDetailsController({
    required this.apiService,
    required this.storageService,
  });

  BuildJob? get job => _job;
  List<BuildStepItem> get steps => _steps;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String? get error => _error;

  Future<void> loadJob(String jobId) async {
    _error = null;
    _job = await storageService.getBuildJob(jobId);
    if (_job != null) {
      _steps = BuildStepItem.defaultSteps();
      notifyListeners();

      if (_job!.isRunning && _job!.runId != null) {
        _startPolling();
      } else if (_job!.runId != null) {
        await _fetchSteps();
      }
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(AppConstants.pollInterval, (_) => _pollStatus());
    _pollStatus();
  }

  Future<void> _pollStatus() async {
    if (_job?.runId == null) return;

    try {
      final status = await apiService.getJobLive(_job!.runId!);
      _updateFromStatus(status);

      if (status.isCompleted) {
        _pollTimer?.cancel();
        _pollTimer = null;
      }
    } catch (e) {
      // Don't set error on transient poll failures
      debugPrint('Poll error: $e');
    }
  }

  void _updateFromStatus(BuildStatusResponse status) {
    if (_job == null) return;

    _job = _job!.copyWith(
      status: status.status,
      conclusion: status.conclusion,
      currentStep: status.currentStep ?? _job!.currentStep,
      totalSteps: status.totalSteps ?? _job!.totalSteps,
      error: status.error,
      completedAt: status.isCompleted ? DateTime.now() : null,
    );

    if (status.steps != null && status.steps!.isNotEmpty) {
      _steps = status.steps!;
    }

    storageService.updateBuildJob(_job!);
    notifyListeners();
  }

  Future<void> _fetchSteps() async {
    if (_job?.runId == null) return;

    try {
      final status = await apiService.getJobLive(_job!.runId!);
      _updateFromStatus(status);
    } catch (_) {
      // Use default steps
    }
  }

  Future<String?> downloadArtifact() async {
    if (_job?.runId == null || _job?.jobId == null) return null;

    _isDownloading = true;
    _downloadProgress = 0;
    _error = null;
    notifyListeners();

    try {
      _downloadProgress = 0.3;
      notifyListeners();

      final zipBytes = await apiService.downloadArtifact(
        runId: _job!.runId!,
        jobId: _job!.jobId,
        prefix: 'apk',
      );

      _downloadProgress = 0.7;
      notifyListeners();

      final apkPath = await _artifactService.saveAndExtractApk(
        zipBytes: zipBytes,
        jobId: _job!.jobId,
        appName: _job!.appName,
      );

      _downloadProgress = 0.9;
      notifyListeners();

      // Update job with APK path
      _job = _job!.copyWith(apkPath: apkPath);
      await storageService.updateBuildJob(_job!);

      // Try to delete artifact from GitHub
      try {
        final artifactInfo = await apiService.getArtifactInfo(
          runId: _job!.runId!,
          jobId: _job!.jobId,
          prefix: 'apk',
        );
        await apiService.deleteArtifact(artifactInfo.artifactId);
      } catch (_) {
        // Non-critical
      }

      _downloadProgress = 1.0;
      _isDownloading = false;
      notifyListeners();

      return apkPath;
    } catch (e) {
      _error = 'Download failed: $e';
      _isDownloading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteJob() async {
    if (_job == null) return;
    _pollTimer?.cancel();
    await storageService.deleteBuildJob(_job!.jobId);
    await _artifactService.cleanupBuild(_job!.jobId);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
