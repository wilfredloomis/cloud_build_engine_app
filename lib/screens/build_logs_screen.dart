import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../services/api_service.dart';

class BuildLogsScreen extends StatefulWidget {
  final String? runId;
  final String jobId;

  const BuildLogsScreen({
    super.key,
    this.runId,
    required this.jobId,
  });

  @override
  State<BuildLogsScreen> createState() => _BuildLogsScreenState();
}

class _BuildLogsScreenState extends State<BuildLogsScreen> {
  String _logs = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    int retries = 0;
    const maxRetries = 5;

    while (retries <= maxRetries) {
      if (retries > 0) {
        await Future.delayed(const Duration(seconds: 8));
      }

      try {
        final api = context.read<ApiService>();
        final logsResponse = await api.getLogs(
          runId: widget.runId,
          jobId: widget.jobId,
        );

        if (!logsResponse.ready && retries < maxRetries) {
          retries++;
          continue;
        }

        setState(() {
          _logs = logsResponse.log.isNotEmpty
              ? logsResponse.log
              : 'No logs available for this build.';
          _isLoading = false;
        });
        return;
      } catch (e) {
        final notReady = e.toString().contains('not ready');
        if (notReady && retries < maxRetries) {
          retries++;
          continue;
        }

        setState(() {
          _error = 'Failed to load logs: $e';
          _isLoading = false;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Logs'),
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy logs',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _logs));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logs copied to clipboard')),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Fetching logs...',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLogs,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
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
                ),
    );
  }
}
