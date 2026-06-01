import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/build_job.dart';
import '../app/theme.dart';
import 'status_badge.dart';
import 'glass_card.dart';

class BuildCard extends StatelessWidget {
  final BuildJob job;
  final VoidCallback? onTap;

  const BuildCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.appName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                status: job.status,
                conclusion: job.conclusion,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job.packageName,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(
                icon: Icons.code,
                label: _projectTypeLabel(job.projectType),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.settings,
                label: job.buildMode,
              ),
              const Spacer(),
              Text(
                _formatTime(job.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (job.isRunning) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: job.progress,
                backgroundColor: AppTheme.dividerColor,
                valueColor: const AlwaysStoppedAnimation(AppTheme.secondaryColor),
                minHeight: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _projectTypeLabel(String type) {
    switch (type) {
      case 'flutter':
        return 'Flutter';
      case 'react_native':
        return 'React Native';
      case 'expo':
        return 'Expo';
      case 'native_android':
        return 'Native';
      default:
        return 'Auto';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(time);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
