import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/constants.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiUrlController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = context.read<LocalStorageService>();
    final url = await storage.getApiUrl();
    _apiUrlController.text = url;
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApiSection(),
            const SizedBox(height: 16),
            _buildAboutSection(),
            const SizedBox(height: 16),
            _buildDangerSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiSection() {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_outlined, size: 20, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'API Configuration',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiUrlController,
            decoration: const InputDecoration(
              labelText: 'Worker API URL',
              hintText: 'https://your-worker.workers.dev',
              prefixIcon: Icon(Icons.link, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveApiUrl,
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _resetApiUrl,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppTheme.secondaryColor),
              SizedBox(width: 8),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _aboutRow('App', AppConstants.appName),
          _aboutRow('Version', AppConstants.appVersion),
          _aboutRow('Flutter SDK', AppConstants.defaultFlutterVersion),
          _aboutRow('Max ZIP Size', '${AppConstants.maxZipSizeMB} MB'),
          const Divider(height: 20),
          const Text(
            'Supported project types',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Flutter · React Native · Expo · Native Android · Capacitor · Cordova · Ionic',
            style: TextStyle(fontSize: 12, color: AppTheme.textPrimary.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerSection() {
    return GlassCard(
      margin: EdgeInsets.zero,
      borderColor: AppTheme.errorColor.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, size: 20, color: AppTheme.errorColor),
              SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _clearHistory,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
              ),
              child: const Text('Clear Build History'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveApiUrl() async {
    setState(() => _isSaving = true);

    final url = _apiUrlController.text.trim();
    if (url.isNotEmpty) {
      final storage = context.read<LocalStorageService>();
      final api = context.read<ApiService>();
      await storage.setApiUrl(url);
      api.setBaseUrl(url);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API URL saved')),
      );
    }
  }

  void _resetApiUrl() {
    _apiUrlController.text = AppConstants.apiBaseUrl;
    final storage = context.read<LocalStorageService>();
    final api = context.read<ApiService>();
    storage.setApiUrl(AppConstants.apiBaseUrl);
    api.setBaseUrl(AppConstants.apiBaseUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API URL reset to default')),
    );
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'This will delete all build records. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final storage = context.read<LocalStorageService>();
      await storage.saveBuildJobs([]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Build history cleared')),
        );
      }
    }
  }
}
