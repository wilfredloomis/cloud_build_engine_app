import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../services/api_service.dart';

class BuildLogsScreen extends StatefulWidget {
  final String runId;
  final String jobId;

  const BuildLogsScreen({
    super.key,
    required this.runId,
    required this.jobId,
  });

  @override
  State<BuildLogsScreen> createState() => _BuildLogsScreenState();
}

class _BuildLogsScreenState extends State<BuildLogsScreen> {
  String _logs = 'Loading logs...';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final api = context.read<ApiService>();
      final status = await api.getJobLive(widget.runId);

      final buffer = StringBuffer();
      buffer.writeln('Build Run: ${widget.runId}');
      buffer.writeln('Job ID: ${widget.jobId}');
      buffer.writeln('Status: ${status.status}');
      if (status.conclusion != null) {
        buffer.writeln('Conclusion: ${status.conclusion}');
      }
      buffer.writeln('');
      buffer.writeln('=== Build Steps ===');
      buffer.writeln('');

      if (status.steps != null) {
        for (final step in status.steps!) {
          final icon = step.isSuccess
              ? '✓'
              : step.isFailed
                  ? '✗'
                  : step.isRunning
                      ? '►'
                      : step.isSkipped
                          ? '⊘'
                          : '○';
          buffer.writeln('  $icon [${step.number}] ${step.name}');
          if (step.conclusion != null) {
            buffer.writeln('    Status: ${step.conclusion}');
          }
        }
      }

      if (status.error != null) {
        buffer.writeln('');
        buffer.writeln('=== Error ===');
        buffer.writeln(status.error);
      }

      setState(() {
        _logs = buffer.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load logs: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadLogs();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppTheme.errorColor),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.errorColor),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: SelectableText(
                      _logs,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
    );
  }
}
