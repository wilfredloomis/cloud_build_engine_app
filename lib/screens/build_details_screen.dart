import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<BuildDetailsController>().refresh(),
          ),
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
                if (job.isFailed || controller.logs != null || controller.isLoadingLogs)
                  _buildLogsSection(controller),
                if (job.error != null && controller.logs == null)
                  _buildErrorSection(job.error!),
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
                if (job.isRunning) ...[
                  Text(
                    'Step ${job.currentStep} / ${job.totalSteps}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (job.stepName != null)
                    Text(
                      job.stepName!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
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
          if (job.packageName.isNotEmpty) _infoRow('Package', job.packageName),
          _infoRow('Mode', job.buildMode),
          _infoRow('Type', _readableProjectType(job.projectType)),
          if (job.runId != null) _infoRow('Run ID', job.runId!),
          if (job.runNumber != null) _infoRow('Run #', '${job.runNumber}'),
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

  Widget _buildLogsSection(BuildDetailsController controller) {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      borderColor: AppTheme.errorColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined, color: AppTheme.errorColor, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Error Logs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
              if (controller.logs != null && controller.logs!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy logs',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: controller.logs!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logs copied to clipboard')),
                    );
                  },
                )
              else if (!controller.isLoadingLogs)
                TextButton(
                  onPressed: () => controller.fetchLogs(),
                  child: const Text('Fetch logs'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (controller.isLoadingLogs)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text(
                  'Fetching logs...',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            )
          else if (controller.logs != null && controller.logs!.isNotEmpty)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: SelectableText(
                  controller.logs!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            )
          else
            const Text(
              'Logs are not available yet.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
        ],
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

  String _readableProjectType(String type) {
    return type.split('_').map((w) => w.isNotEmpty
        ? '${w[0].toUpperCase()}${w.substring(1)}'
        : w).join(' ');
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
        Navigator.pushNamed(
          context,
          AppRoutes.buildLogs,
          arguments: {'runId': job.runId, 'jobId': job.jobId},
        );
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
