import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../app/theme.dart';
import '../app/routes.dart';
import '../controllers/build_details_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/build_step_tile.dart';
import '../widgets/progress_button.dart';

class BuildDetailsScreen extends StatefulWidget {
  final String jobId;

  const BuildDetailsScreen({super.key, required this.jobId});

  @override
  State<BuildDetailsScreen> createState() => _BuildDetailsScreenState();
}

class _BuildDetailsScreenState extends State<BuildDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BuildDetailsController>().loadJob(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Details'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logs',
                child: Row(
                  children: [
                    Icon(Icons.article_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('View Logs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Delete Build', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<BuildDetailsController>(
        builder: (context, controller, _) {
          if (controller.job == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final job = controller.job!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(job, controller),
                _buildInfoCard(job),
                _buildStepsSection(controller),
                if (job.isSuccess) _buildDownloadSection(controller),
                if (job.error != null) _buildErrorSection(job.error!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(dynamic job, BuildDetailsController controller) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (job.isSuccess) {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
      statusText = 'Build Successful';
    } else if (job.isFailed) {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.error;
      statusText = 'Build Failed';
    } else if (job.isRunning) {
      statusColor = AppTheme.secondaryColor;
      statusIcon = Icons.build_circle;
      statusText = 'Building...';
    } else {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.schedule;
      statusText = job.statusDisplay;
    }

    return GlassCard(
      margin: const EdgeInsets.all(16),
      borderColor: statusColor.withOpacity(0.3),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 36,
            lineWidth: 4,
            percent: job.isSuccess
                ? 1.0
                : job.isFailed
                    ? 1.0
                    : job.progress,
            center: Icon(statusIcon, color: statusColor, size: 28),
            progressColor: statusColor,
            backgroundColor: AppTheme.dividerColor,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (job.duration != null)
                  Text(
                    'Duration: ${_formatDuration(job.duration!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                if (job.isRunning)
                  Text(
                    'Step ${job.currentStep} / ${job.totalSteps}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          StatusBadge(status: job.status, conclusion: job.conclusion),
        ],
      ),
    );
  }

  Widget _buildInfoCard(dynamic job) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build Info',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow('App Name', job.appName),
          _infoRow('Package', job.packageName),
          _infoRow('Mode', job.buildMode),
          _infoRow('Type', job.projectType),
          if (job.runId != null) _infoRow('Run ID', job.runId!),
          _infoRow('Job ID', job.jobId),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(BuildDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 16, 8),
          child: Text(
            'Build Steps',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        ...controller.steps.map(
          (step) => BuildStepTile(step: step),
        ),
      ],
    );
  }

  Widget _buildDownloadSection(BuildDetailsController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ProgressButton(
        label: 'Download APK',
        icon: Icons.download,
        color: AppTheme.successColor,
        isLoading: controller.isDownloading,
        loadingLabel: 'Downloading...',
        progress: controller.isDownloading ? controller.downloadProgress : null,
        onPressed: () async {
          final apkPath = await controller.downloadArtifact();
          if (apkPath != null && mounted) {
            Navigator.pushNamed(
              context,
              AppRoutes.result,
              arguments: {
                'jobId': widget.jobId,
                'apkPath': apkPath,
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      borderColor: AppTheme.errorColor.withOpacity(0.3),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    }
    return '${d.inSeconds}s';
  }

  void _handleMenuAction(String action) async {
    final controller = context.read<BuildDetailsController>();
    final job = controller.job;
    if (job == null) return;

    switch (action) {
      case 'logs':
        if (job.runId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.buildLogs,
            arguments: {'runId': job.runId, 'jobId': job.jobId},
          );
        }
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Build'),
            content: const Text('Are you sure you want to delete this build record?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
              ),
            ],
          ),
        );
        if (confirm == true && mounted) {
          await controller.deleteJob();
          Navigator.pop(context);
        }
        break;
    }
  }
}
