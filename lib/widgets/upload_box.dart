import 'package:flutter/material.dart';
import '../app/theme.dart';

class UploadBox extends StatelessWidget {
  final String? fileName;
  final String? fileSize;
  final VoidCallback onTap;
  final bool isLoading;

  const UploadBox({
    super.key,
    this.fileName,
    this.fileSize,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile
                ? AppTheme.successColor.withOpacity(0.3)
                : AppTheme.primaryColor.withOpacity(0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          color: hasFile
              ? AppTheme.successColor.withOpacity(0.05)
              : AppTheme.primaryColor.withOpacity(0.05),
        ),
        child: Column(
          children: [
            if (isLoading) ...[
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(height: 12),
              const Text('Reading file...', style: TextStyle(color: AppTheme.textSecondary)),
            ] else if (hasFile) ...[
              const Icon(Icons.folder_zip, size: 40, color: AppTheme.successColor),
              const SizedBox(height: 12),
              Text(
                fileName!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (fileSize != null) ...[
                const SizedBox(height: 4),
                Text(
                  fileSize!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Tap to change',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor.withOpacity(0.7),
                ),
              ),
            ] else ...[
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select ZIP Source Project',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to browse files',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
