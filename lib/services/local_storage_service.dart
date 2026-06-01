import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/constants.dart';
import '../models/build_job.dart';

class LocalStorageService {
  Future<List<BuildJob>> getBuildJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.storageKeyBuildJobs);
    if (data == null) return [];

    final list = json.decode(data) as List;
    return list
        .map((e) => BuildJob.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveBuildJobs(List<BuildJob> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(jobs.map((j) => j.toJson()).toList());
    await prefs.setString(AppConstants.storageKeyBuildJobs, data);
  }

  Future<void> addBuildJob(BuildJob job) async {
    final jobs = await getBuildJobs();
    jobs.insert(0, job);
    await saveBuildJobs(jobs);
  }

  Future<void> updateBuildJob(BuildJob job) async {
    final jobs = await getBuildJobs();
    final index = jobs.indexWhere((j) => j.jobId == job.jobId);
    if (index >= 0) {
      jobs[index] = job;
    } else {
      jobs.insert(0, job);
    }
    await saveBuildJobs(jobs);
  }

  Future<void> deleteBuildJob(String jobId) async {
    final jobs = await getBuildJobs();
    jobs.removeWhere((j) => j.jobId == jobId);
    await saveBuildJobs(jobs);
  }

  Future<BuildJob?> getBuildJob(String jobId) async {
    final jobs = await getBuildJobs();
    try {
      return jobs.firstWhere((j) => j.jobId == jobId);
    } catch (_) {
      return null;
    }
  }

  Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.storageKeyApiUrl) ??
        AppConstants.apiBaseUrl;
  }

  Future<void> setApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.storageKeyApiUrl, url);
  }
}
