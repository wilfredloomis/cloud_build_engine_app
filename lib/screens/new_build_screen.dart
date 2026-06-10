import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/routes.dart';
import '../app/constants.dart';
import '../controllers/new_build_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/upload_box.dart';
import '../widgets/progress_button.dart';

class NewBuildScreen extends StatefulWidget {
  const NewBuildScreen({super.key});

  @override
  State<NewBuildScreen> createState() => _NewBuildScreenState();
}

class _NewBuildScreenState extends State<NewBuildScreen> {
  final _appNameController = TextEditingController();
  final _packageNameController = TextEditingController();
  final _flutterVersionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = context.read<NewBuildController>();
    controller.reset();
    _flutterVersionController.text = AppConstants.defaultFlutterVersion;
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _packageNameController.dispose();
    _flutterVersionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Build'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<NewBuildController>(
        builder: (context, controller, _) {
          // Sync text fields when controller updates
          if (controller.appName.isNotEmpty &&
              _appNameController.text != controller.appName) {
            _appNameController.text = controller.appName;
          }
          if (controller.packageName.isNotEmpty &&
              _packageNameController.text != controller.packageName) {
            _packageNameController.text = controller.packageName;
          }

          // Navigate on build complete
          if (controller.state == BuildState.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.buildDetails,
                arguments: {'jobId': controller.createdJobId},
              );
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                _buildUploadSection(controller),
                if (controller.selectedFile != null) ...[
                  _buildAppNameField(controller),
                  _buildPackageNameField(controller),
                  _buildBuildConfig(controller),
                  const SizedBox(height: 24),
                  _buildStartButton(controller),
                ],
                if (controller.error != null) _buildError(controller.error!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      borderColor: AppTheme.primaryColor.withOpacity(0.2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Source Project',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Select a ZIP file containing your Flutter, React Native, Expo, or Native Android project.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(NewBuildController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: UploadBox(
        fileName: controller.selectedFile?.name,
        fileSize: controller.selectedFile?.sizeFormatted,
        onTap: () => controller.pickFile(),
        isLoading: controller.state == BuildState.picking,
      ),
    );
  }

  Widget _buildAppNameField(NewBuildController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _appNameController,
        onChanged: controller.setAppName,
        decoration: const InputDecoration(
          labelText: 'App Name',
          hintText: 'e.g., MyApp',
          prefixIcon: Icon(Icons.apps, size: 20),
        ),
      ),
    );
  }

  Widget _buildPackageNameField(NewBuildController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _packageNameController,
        onChanged: controller.setPackageName,
        decoration: const InputDecoration(
          labelText: 'Package Name',
          hintText: 'e.g., com.example.myapp',
          prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
        ),
      ),
    );
  }

  Widget _buildBuildConfig(NewBuildController controller) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build Configuration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Build mode
          const Text(
            'Build Mode',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildModeChip('Release', AppConstants.modeRelease, controller),
              const SizedBox(width: 8),
              _buildModeChip('Debug', AppConstants.modeDebug, controller),
            ],
          ),
          const SizedBox(height: 12),

          // Project type
          const Text(
            'Project Type',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip('Auto-detect', AppConstants.typeAuto, controller),
              _buildTypeChip('Flutter', AppConstants.typeFlutter, controller),
              _buildTypeChip('React Native', AppConstants.typeReactNative, controller),
              _buildTypeChip('Native', AppConstants.typeNativeAndroid, controller),
            ],
          ),

          if (controller.projectType == AppConstants.typeFlutter) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _flutterVersionController,
              onChanged: controller.setFlutterVersion,
              decoration: const InputDecoration(
                labelText: 'Flutter Version',
                hintText: '3.44.1',
                prefixIcon: Icon(Icons.flutter_dash, size: 20),
                isDense: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeChip(
      String label, String value, NewBuildController controller) {
    final isSelected = controller.buildMode == value;
    return GestureDetector(
      onTap: () => controller.setBuildMode(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.2)
              : AppTheme.cardColor,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
      String label, String value, NewBuildController controller) {
    final isSelected = controller.projectType == value;
    return GestureDetector(
      onTap: () => controller.setProjectType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? AppTheme.secondaryColor.withOpacity(0.15)
              : AppTheme.cardColor,
          border: Border.all(
            color: isSelected
                ? AppTheme.secondaryColor
                : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected
                ? AppTheme.secondaryColor
                : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(NewBuildController controller) {
    final isUploading = controller.state == BuildState.uploading;
    final isDispatching = controller.state == BuildState.dispatching;
    final isWorking = isUploading || isDispatching;

    String loadingLabel;
    if (isUploading) {
      loadingLabel = 'Uploading...';
    } else if (isDispatching) {
      loadingLabel = 'Starting build...';
    } else {
      loadingLabel = 'Processing...';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProgressButton(
        label: 'Start Build',
        icon: Icons.rocket_launch,
        isLoading: isWorking,
        loadingLabel: loadingLabel,
        progress: isUploading ? controller.uploadProgress : null,
        onPressed: () => controller.startBuild(),
      ),
    );
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.errorColor.withOpacity(0.1),
          border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 18),
            const SizedBox(width: 8),
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
      ),
    );
  }
}
