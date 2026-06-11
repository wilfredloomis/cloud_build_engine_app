import 'package:flutter/foundation.dart';
import '../models/build_job.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/artifact_service.dart';

class HomeController extends ChangeNotifier {
  final ApiService apiService;
  final LocalStorageService storageService;
  final ArtifactService _artifactService = ArtifactService();

  List<BuildJob> _jobs = [];
  bool _isLoading = false;
  String? _error;
  final List<String> _downloadedOnResume = [];

  HomeController({
    required this.apiService,
    required this.storageService,
  });

  List<BuildJob> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get downloadedOnResume => _downloadedOnResume;

  int get totalBuilds => _jobs.length;
  int get runningBuilds => _jobs.where((j) => j.isRunning).length;
  int get successBuilds => _jobs.where((j) => j.isSuccess).length;
  int get failedBuilds => _jobs.where((j) => j.isFailed).length;

  Future<void> loadJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jobs = await storageService.getBuildJobs();
    } catch (e) {
      _error = 'Failed to load build history: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshRunningJobs() async {
    final runningJobs = _jobs.where((j) => j.isRunning).toList();
    bool changed = false;

    for (final job in runningJobs) {
      try {
        final status = await apiService.getStatus(
          runId: job.runId,
          jobId: job.jobId,
        );
        final resolvedRunId = status.runId ?? job.runId;
        final updated = job.copyWith(
          runId: resolvedRunId,
          runNumber: status.runNumber ?? job.runNumber,
          status: status.status,
          conclusion: status.conclusion,
          currentStep: status.currentStep ?? job.currentStep,
          totalSteps: status.totalSteps ?? job.totalSteps,
          stepName: status.stepName,
          steps: status.steps ?? job.steps,
          completedAt: status.isCompleted ? DateTime.now() : null,
          error: status.error,
        );

        final index = _jobs.indexWhere((j) => j.jobId == job.jobId);
        if (index >= 0) {
          _jobs[index] = updated;
          await storageService.updateBuildJob(updated);
          changed = true;
        }
      } catch (_) {
        // Silently skip failed status checks
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Called on app resume to check if any previously-running builds
  /// have completed and are ready to download.
  Future<void> checkAndDownloadCompleted() async {
    await loadJobs();
    await refreshRunningJobs();

    _downloadedOnResume.clear();

    final readyToDownload = _jobs.where(
      (j) => j.isSuccess && j.apkPath == null,
    ).toList();

    for (final job in readyToDownload) {
      if (job.runId == null) continue;
      try {
        final zipBytes = await apiService.downloadArtifact(
          runId: job.runId!,
          jobId: job.jobId,
          prefix: 'apk',
        );

        final apkPath = await _artifactService.saveAndExtractApk(
          zipBytes: zipBytes,
          jobId: job.jobId,
          appName: job.appName,
        );

        final updated = job.copyWith(apkPath: apkPath);
        final index = _jobs.indexWhere((j) => j.jobId == job.jobId);
        if (index >= 0) {
          _jobs[index] = updated;
          await storageService.updateBuildJob(updated);
        }
        _downloadedOnResume.add(job.appName);

        // Try to delete artifact from server
        try {
          final artifactInfo = await apiService.getArtifactInfo(
            runId: job.runId!,
            jobId: job.jobId,
            prefix: 'apk',
          );
          await apiService.deleteArtifact(artifactInfo.artifactId);
        } catch (_) {}
      } catch (_) {
        // Skip failed downloads silently
      }
    }

    if (_downloadedOnResume.isNotEmpty) {
      notifyListeners();
    }
  }

  void clearDownloadedOnResume() {
    _downloadedOnResume.clear();
  }

  Future<void> deleteJob(String jobId) async {
    _jobs.removeWhere((j) => j.jobId == jobId);
    await storageService.deleteBuildJob(jobId);
    notifyListeners();
  }
}
