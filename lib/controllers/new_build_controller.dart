import 'package:flutter/foundation.dart';
import '../models/build_job.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/file_picker_service.dart';
import '../services/zip_extract_service.dart';
import '../app/constants.dart';

enum BuildState { idle, picking, uploading, dispatching, done, error }

class NewBuildController extends ChangeNotifier {
  final ApiService apiService;
  final LocalStorageService storageService;
  final FilePickerService _filePicker = FilePickerService();
  final ZipExtractService _zipExtract = ZipExtractService();

  BuildState _state = BuildState.idle;
  PickedFile? _selectedFile;
  ZipInfo? _zipInfo;
  String _appName = '';
  String _packageName = '';
  String _buildMode = AppConstants.modeRelease;
  String _projectType = AppConstants.typeAuto;
  String _flutterVersion = AppConstants.defaultFlutterVersion;
  double _uploadProgress = 0;
  String? _error;
  String? _createdJobId;
  String? _createdRunId;

  NewBuildController({
    required this.apiService,
    required this.storageService,
  });

  BuildState get state => _state;
  PickedFile? get selectedFile => _selectedFile;
  ZipInfo? get zipInfo => _zipInfo;
  String get appName => _appName;
  String get packageName => _packageName;
  String get buildMode => _buildMode;
  String get projectType => _projectType;
  String get flutterVersion => _flutterVersion;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;
  String? get createdJobId => _createdJobId;
  String? get createdRunId => _createdRunId;

  void setAppName(String value) {
    _appName = value;
    notifyListeners();
  }

  void setPackageName(String value) {
    _packageName = value;
    notifyListeners();
  }

  void setBuildMode(String value) {
    _buildMode = value;
    notifyListeners();
  }

  void setProjectType(String value) {
    _projectType = value;
    notifyListeners();
  }

  void setFlutterVersion(String value) {
    _flutterVersion = value;
    notifyListeners();
  }

  Future<void> pickFile() async {
    _state = BuildState.picking;
    _error = null;
    notifyListeners();

    try {
      final file = await _filePicker.pickZipFile();
      if (file == null) {
        _state = BuildState.idle;
        notifyListeners();
        return;
      }

      if (file.size > AppConstants.maxZipSizeBytes) {
        _error = 'File too large. Maximum size is ${AppConstants.maxZipSizeMB} MB';
        _state = BuildState.error;
        notifyListeners();
        return;
      }

      _selectedFile = file;

      // Try to detect project type from ZIP contents
      _zipInfo = _zipExtract.inspectZip(file.bytes);
      if (_zipInfo != null) {
        if (_zipInfo!.projectType != null) {
          _projectType = _zipInfo!.projectType!;
        }
        if (_zipInfo!.detectedPackageName != null && _packageName.isEmpty) {
          _packageName = _zipInfo!.detectedPackageName!;
        }
      }

      // Default app name from filename
      if (_appName.isEmpty) {
        _appName = file.name.replaceAll('.zip', '').replaceAll(RegExp(r'[_-]'), ' ');
      }

      _state = BuildState.idle;
    } catch (e) {
      _error = 'Failed to pick file: $e';
      _state = BuildState.error;
    }

    notifyListeners();
  }

  Future<void> startBuild() async {
    if (_selectedFile == null) {
      _error = 'Please select a ZIP file first';
      _state = BuildState.error;
      notifyListeners();
      return;
    }

    if (_appName.isEmpty) {
      _error = 'Please enter an app name';
      _state = BuildState.error;
      notifyListeners();
      return;
    }

    try {
      // Step 1: Prepare upload
      _state = BuildState.uploading;
      _uploadProgress = 0;
      _error = null;
      notifyListeners();

      final prepare = await apiService.prepareUpload(ext: 'zip');

      // Step 2: Upload ZIP
      final upload = await apiService.uploadZip(
        uploadUrl: prepare.uploadUrl,
        fileBytes: _selectedFile!.bytes,
        fileName: _selectedFile!.name,
      );
      _uploadProgress = 1.0;
      notifyListeners();

      // Step 3: Dispatch build (pass asset_id and source_url from upload)
      _state = BuildState.dispatching;
      notifyListeners();

      final dispatch = await apiService.dispatchJob(
        jobId: prepare.jobId,
        assetId: upload.assetId.toString(),
        sourceUrl: upload.sourceUrl,
        appName: _appName,
        packageName: _packageName,
        flutterVersion: _flutterVersion,
        buildMode: _buildMode,
        projectType: _projectType,
      );

      // Step 4: Save build record
      final job = BuildJob(
        jobId: prepare.jobId,
        runId: dispatch.runId,
        runNumber: dispatch.runNumber,
        appName: _appName,
        packageName: _packageName,
        buildMode: _buildMode,
        projectType: _projectType,
        status: 'queued',
        currentStep: 0,
        totalSteps: 26,
        createdAt: DateTime.now(),
      );

      await storageService.addBuildJob(job);

      _createdJobId = prepare.jobId;
      _createdRunId = dispatch.runId;
      _state = BuildState.done;
    } catch (e) {
      _error = 'Build failed: $e';
      _state = BuildState.error;
    }

    notifyListeners();
  }

  void reset() {
    _state = BuildState.idle;
    _selectedFile = null;
    _zipInfo = null;
    _appName = '';
    _packageName = '';
    _buildMode = AppConstants.modeRelease;
    _projectType = AppConstants.typeAuto;
    _flutterVersion = AppConstants.defaultFlutterVersion;
    _uploadProgress = 0;
    _error = null;
    _createdJobId = null;
    _createdRunId = null;
    notifyListeners();
  }
}
