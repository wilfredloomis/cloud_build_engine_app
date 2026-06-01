import 'package:flutter/foundation.dart';
import '../models/build_job.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class HomeController extends ChangeNotifier {
  final ApiService apiService;
  final LocalStorageService storageService;

  List<BuildJob> _jobs = [];
  bool _isLoading = false;
  String? _error;

  HomeController({
    required this.apiService,
    required this.storageService,
  });

  List<BuildJob> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
      if (job.runId == null) continue;

      try {
        final status = await apiService.getStatus(job.runId!);
        final updated = job.copyWith(
          status: status.status,
          conclusion: status.conclusion,
          currentStep: status.currentStep ?? job.currentStep,
          totalSteps: status.totalSteps ?? job.totalSteps,
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

  Future<void> deleteJob(String jobId) async {
    _jobs.removeWhere((j) => j.jobId == jobId);
    await storageService.deleteBuildJob(jobId);
    notifyListeners();
  }
}
