import 'package:flutter/material.dart';
import '../models/build_step_item.dart';
import '../app/theme.dart';

class BuildStepTile extends StatelessWidget {
  final BuildStepItem step;

  const BuildStepTile({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.name,
              style: TextStyle(
                fontSize: 13,
                color: _textColor(),
                fontWeight: step.isRunning ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${step.number}',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (step.isRunning) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(AppTheme.secondaryColor),
        ),
      );
    }

    if (step.isCompleted) {
      if (step.isFailed) {
        return const Icon(Icons.close, size: 18, color: AppTheme.errorColor);
      }
      if (step.isSkipped) {
        return Icon(
          Icons.skip_next,
          size: 18,
          color: AppTheme.textSecondary.withOpacity(0.5),
        );
      }
      return const Icon(Icons.check_circle, size: 18, color: AppTheme.successColor);
    }

    return Icon(
      Icons.circle_outlined,
      size: 18,
      color: AppTheme.textSecondary.withOpacity(0.3),
    );
  }

  Color _textColor() {
    if (step.isRunning) return AppTheme.secondaryColor;
    if (step.isCompleted && step.isFailed) return AppTheme.errorColor;
    if (step.isCompleted && step.isSkipped) {
      return AppTheme.textSecondary.withOpacity(0.5);
    }
    if (step.isCompleted) return AppTheme.textPrimary;
    return AppTheme.textSecondary.withOpacity(0.5);
  }
}
