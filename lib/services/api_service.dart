import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../app/constants.dart';
import '../models/prepare_upload_response.dart';
import '../models/upload_response.dart';
import '../models/dispatch_response.dart';
import '../models/build_status_response.dart';
import '../models/artifact_response.dart';
import '../models/build_logs_response.dart';

class ApiService {
  String _baseUrl = AppConstants.apiBaseUrl;

  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<PrepareUploadResponse> prepareUpload({String ext = 'zip'}) async {
    final uri = Uri.parse('$_baseUrl/prepare-upload?ext=$ext');
    final response = await http.get(uri);
    _checkResponse(response);
    return PrepareUploadResponse.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  Future<UploadResponse> uploadZip({
    required String uploadUrl,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse(uploadUrl);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _checkResponse(response);
    return UploadResponse.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  Future<DispatchResponse> dispatchJob({
    required String jobId,
    required String appName,
    required String packageName,
    String? assetId,
    String? sourceUrl,
    String flutterVersion = AppConstants.defaultFlutterVersion,
    String buildMode = 'release',
    String projectType = 'auto',
  }) async {
    final uri = Uri.parse('$_baseUrl/dispatch-job');
    final body = <String, dynamic>{
      'job_id': jobId,
      'app_name': appName,
      'package_name': packageName,
      'flutter_version': flutterVersion,
      'build_mode': buildMode,
      'project_type': projectType,
    };
    if (assetId != null) body['asset_id'] = assetId;
    if (sourceUrl != null) body['source_url'] = sourceUrl;
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    _checkResponse(response);
    return DispatchResponse.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  Future<BuildStatusResponse> getStatus({String? runId, String? jobId}) async {
    final params = <String, String>{};
    if (runId != null) params['run_id'] = runId;
    if (jobId != null) params['job_id'] = jobId;
    final uri = Uri.parse('$_baseUrl/status').replace(queryParameters: params);
    final response = await http.get(uri);
    _checkResponse(response);
    return BuildStatusResponse.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  Future<BuildStatusResponse> getJobLive({String? runId, String? jobId}) async {
    final params = <String, String>{};
    if (runId != null) params['run_id'] = runId;
    if (jobId != null) params['job_id'] = jobId;
    final uri = Uri.parse('$_baseUrl/job-live').replace(queryParameters: params);
    final response = await http.get(uri);
    _checkResponse(response);
    return BuildStatusResponse.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  Future<BuildLogsResponse> getLogs({String? runId, String? jobId}) async {
    final params = <String, String>{};
    if (runId != null) params['run_id'] = runId;
    if (jobId != null) params['job_id'] = jobId;
    final uri = Uri.parse('$_baseUrl/logs').replace(queryParameters: params);
    final response = await http.get(uri);
    _checkResponse(response);
    return BuildLogsResponse.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  Future<ArtifactResponse> getArtifactInfo({
    required String runId,
    required String jobId,
    String prefix = 'apk',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/artifact-info?run_id=$runId&job_id=$jobId&prefix=$prefix',
    );
    final response = await http.get(uri);
    _checkResponse(response);
    return ArtifactResponse.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Uint8List> downloadArtifact({
    required String runId,
    required String jobId,
    String prefix = 'apk',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/artifact?run_id=$runId&job_id=$jobId&prefix=$prefix',
    );
    final response = await http.get(uri);
    _checkResponse(response);
    return response.bodyBytes;
  }

  Future<void> deleteArtifact(int artifactId) async {
    final uri = Uri.parse('$_baseUrl/delete-artifact?artifact_id=$artifactId');
    final response = await http.delete(uri);
    _checkResponse(response);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message;
      try {
        final body = json.decode(response.body) as Map<String, dynamic>;
        message = body['error'] as String? ??
            body['message'] as String? ??
            'Request failed';
      } catch (_) {
        message = 'Request failed with status ${response.statusCode}';
      }
      throw ApiException(message, response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
