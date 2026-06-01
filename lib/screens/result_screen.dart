import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../app/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_button.dart';

class ResultScreen extends StatelessWidget {
  final String jobId;
  final String? apkPath;

  const ResultScreen({
    super.key,
    required this.jobId,
    this.apkPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Build Result')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.successColor.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'APK Ready!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Job: $jobId',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
              if (apkPath != null) ...[
                const SizedBox(height: 8),
                GlassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.android, color: AppTheme.successColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apkPath!.split('/').last,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            FutureBuilder<int>(
                              future: _getFileSize(apkPath!),
                              builder: (_, snap) {
                                if (!snap.hasData) return const SizedBox();
                                return Text(
                                  _formatSize(snap.data!),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ProgressButton(
                  label: 'Install APK',
                  icon: Icons.install_mobile,
                  color: AppTheme.successColor,
                  onPressed: () => _installApk(),
                ),
                const SizedBox(height: 12),
                ProgressButton(
                  label: 'Share APK',
                  icon: Icons.share,
                  color: AppTheme.primaryColor,
                  onPressed: () => _shareApk(),
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _getFileSize(String path) async {
    try {
      final file = File(path);
      return await file.length();
    } catch (_) {
      return 0;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _installApk() {
    if (apkPath != null) {
      OpenFilex.open(apkPath!);
    }
  }

  void _shareApk() {
    if (apkPath != null) {
      Share.shareXFiles([XFile(apkPath!)]);
    }
  }
}
