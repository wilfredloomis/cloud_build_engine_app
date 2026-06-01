import 'dart:typed_data';
import 'package:http/http.dart' as http;

class UploadService {
  Future<void> uploadWithProgress({
    required String uploadUrl,
    required Uint8List fileBytes,
    required String fileName,
    required void Function(int sent, int total) onProgress,
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

    final total = fileBytes.length;
    onProgress(0, total);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    onProgress(total, total);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload failed with status ${response.statusCode}');
    }
  }
}
