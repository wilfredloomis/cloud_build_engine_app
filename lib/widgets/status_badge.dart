import 'package:flutter/material.dart';
import '../app/theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? conclusion;

  const StatusBadge({
    super.key,
    required this.status,
    this.conclusion,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    if (status == 'completed') {
      switch (conclusion) {
        case 'success':
          return _BadgeConfig(
            'Success',
            AppTheme.successColor,
            Icons.check_circle_outline,
          );
        case 'failure':
          return _BadgeConfig(
            'Failed',
            AppTheme.errorColor,
            Icons.error_outline,
          );
        case 'cancelled':
          return _BadgeConfig(
            'Cancelled',
            AppTheme.textSecondary,
            Icons.cancel_outlined,
          );
        case 'timed_out':
          return _BadgeConfig(
            'Timed Out',
            AppTheme.warningColor,
            Icons.timer_off_outlined,
          );
        default:
          return _BadgeConfig(
            'Completed',
            AppTheme.textSecondary,
            Icons.done,
          );
      }
    }

    switch (status) {
      case 'created':
        return _BadgeConfig(
          'Waiting',
          AppTheme.textSecondary,
          Icons.hourglass_empty,
        );
      case 'uploading':
        return _BadgeConfig(
          'Uploading',
          AppTheme.primaryColor,
          Icons.cloud_upload_outlined,
        );
      case 'uploaded':
        return _BadgeConfig(
          'Uploaded',
          AppTheme.primaryColor,
          Icons.cloud_done_outlined,
        );
      case 'queued':
        return _BadgeConfig(
          'Queued',
          AppTheme.warningColor,
          Icons.schedule,
        );
      case 'in_progress':
        return _BadgeConfig(
          'Building',
          AppTheme.secondaryColor,
          Icons.build_circle_outlined,
        );
      default:
        return _BadgeConfig(
          status,
          AppTheme.textSecondary,
          Icons.help_outline,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color color;
  final IconData icon;

  _BadgeConfig(this.label, this.color, this.icon);
}
